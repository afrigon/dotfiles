#!/usr/bin/env bash

input=$(cat)

field() { jq -r "$1 // empty" <<<"$input"; }

reset=$'\e[0m' dim=$'\e[2m' bold=$'\e[1m'
cyan=$'\e[36m' green=$'\e[32m' yellow=$'\e[33m' red=$'\e[31m' blue=$'\e[34m' magenta=$'\e[35m'

current_dir=$(field '.workspace.current_dir')
[ -n "$current_dir" ] || current_dir=$(field '.cwd')

# user, directory, worktree, git
line="${cyan}${USER}${reset} ${dim}@${reset} ${bold}${current_dir/#$HOME/\~}${reset}"
if branch=$(git -C "$current_dir" symbolic-ref --short -q HEAD 2>/dev/null) \
    || branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null); then
  git_dir=$(git -C "$current_dir" rev-parse --absolute-git-dir 2>/dev/null)
  common_dir=$(git -C "$current_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  if [ -n "$git_dir" ] && [ "$git_dir" != "$common_dir" ]; then
    worktree=$(basename "$(git -C "$current_dir" rev-parse --show-toplevel)")
    line+=" ${magenta}[worktree: ${worktree}]${reset}"
  fi
  line+="  ${green}${branch}${reset}"
  if upstream_counts=$(git -C "$current_dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    read -r behind ahead <<<"$upstream_counts"
    [ "$ahead" -gt 0 ] && line+=" ${yellow}↑${ahead}${reset}"
    [ "$behind" -gt 0 ] && line+=" ${yellow}↓${behind}${reset}"
  fi
  changed=$(git -C "$current_dir" status --porcelain 2>/dev/null | wc -l)
  [ "$changed" -gt 0 ] && line+=" ${red}✚${changed}${reset}"
fi
printf '%s\n' "$line"

# model, effort, context, rate limits
line="${blue}$(field '.model.display_name')${reset}"
effort=$(field '.effort.level')
[ -n "$effort" ] && line+=" ${dim}(${effort})${reset}"

humanize() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%.3gM", n / 1000000
    else if (n >= 1000) printf "%.3gk", n / 1000
    else printf "%d", n
  }'
}

grade() {
  if [ "$1" -ge 90 ]; then printf '%s' "$red"
  elif [ "$1" -ge 70 ]; then printf '%s' "$yellow"
  else printf '%s' "$green"; fi
}

used_tokens=$(field '.context_window.total_input_tokens')
window_size=$(field '.context_window.context_window_size')
if [ -n "$used_tokens" ] && [ -n "$window_size" ]; then
  percentage=$((used_tokens * 100 / window_size))
  color=$(grade "$percentage")
  line+=" ${dim}·${reset} ${color}$(humanize "$used_tokens")${reset}${dim}/$(humanize "$window_size")${reset} ${color}${percentage}%${reset}"
fi

# the prompt cache expires 5 minutes after the last request; transcript mtime tracks that
transcript_path=$(field '.transcript_path')
if [ "${used_tokens:-0}" -gt 0 ] && [ -f "$transcript_path" ] \
    && [ $(( $(date +%s) - $(stat -c %Y "$transcript_path") )) -ge 300 ]; then
  line+=" ${yellow}⚠ expired${reset}"
fi

five_hour_used=$(field '.rate_limits.five_hour.used_percentage')
if [ -n "$five_hour_used" ]; then
  five_hour_used=${five_hour_used%%.*}
  five_hour_resets=$(date -d "@$(field '.rate_limits.five_hour.resets_at')" +%H:%M 2>/dev/null)
  line+=" ${dim}·${reset} 5h $(grade "$five_hour_used")${five_hour_used}%${reset}"
  [ -n "$five_hour_resets" ] && line+=" ${dim}(resets ${five_hour_resets})${reset}"
fi

seven_day_used=$(field '.rate_limits.seven_day.used_percentage')
if [ -n "$seven_day_used" ]; then
  seven_day_used=${seven_day_used%%.*}
  line+=" ${dim}·${reset} 7d $(grade "$seven_day_used")${seven_day_used}%${reset}"
fi

printf '%s\n' "$line"

# aws — omitted entirely when no profile is configured
profile=${AWS_PROFILE:-}
if [ -z "$profile" ] && grep -qsE '^\[(profile )?default\]' "$HOME/.aws/config" "$HOME/.aws/credentials"; then
  profile=default
fi
if [ -n "$profile" ]; then
  session_ok=yes
  if command -v aws >/dev/null 2>&1; then
    cache_file="${XDG_RUNTIME_DIR:-/tmp}/claude-statusline-aws-${profile}"
    # sts round-trip is too slow to run on every refresh; cache the verdict for 5 minutes
    if ! [ -f "$cache_file" ] || [ $(( $(date +%s) - $(stat -c %Y "$cache_file") )) -ge 300 ]; then
      if timeout 3 aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
        echo ok > "$cache_file"
      else
        echo expired > "$cache_file"
      fi
    fi
    [ "$(cat "$cache_file")" = ok ] || session_ok=no
  fi
  if [ "$session_ok" = yes ]; then
    line="aws: ${cyan}${profile}${reset}"
    region=${AWS_REGION:-${AWS_DEFAULT_REGION:-}}
    if [ -z "$region" ] && [ -f "$HOME/.aws/config" ]; then
      region=$(awk -v p="$profile" '
        /^\[/ { active = ($0 == "[" p "]" || $0 == "[profile " p "]") }
        active && $1 == "region" { print $NF; exit }' "$HOME/.aws/config")
    fi
    [ -n "$region" ] && line+=" ${dim}(${region})${reset}"
    printf '%s\n' "$line"
  fi
fi
