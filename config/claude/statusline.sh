#!/usr/bin/env bash
input=$(cat)

five_hour=$(jq -r '.rate_limits.five_hour.used_percentage // empty | round' <<<"$input" 2>/dev/null)
seven_day=$(jq -r '.rate_limits.seven_day.used_percentage // empty | round' <<<"$input" 2>/dev/null)
[ -n "$five_hour" ] && export CLAUDE_RATE_LIMIT_FIVE_HOUR="$five_hour"
[ -n "$seven_day" ] && export CLAUDE_RATE_LIMIT_SEVEN_DAY="$seven_day"

exec starship statusline claude-code <<<"$input"
