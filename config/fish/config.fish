set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR
set -x SUDO_EDITOR $EDITOR
set -x VISUAL $EDITOR
set -x BROWSER firefox

set -q XDG_CONFIG_HOME; or set -x XDG_CONFIG_HOME $HOME/.config

set -x CLAUDE_CONFIG_DIR $XDG_CONFIG_HOME/claude
set -x STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml

# disable fish greeting
set -g fish_greeting

# disable working directory truncation
set -g fish_prompt_pwd_dir_length 0

# editor
alias e="$EDITOR"
alias v="$EDITOR"
alias vi="$EDITOR"
alias vim="$EDITOR"

# navigation
alias s="cd $HOME/src"

alias quit="exit"

# package managers
if test (uname) = Darwin; and test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

if command -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

# Auto-start Hyprland on TTY login (via uwsm — Hyprland's recommended launch method).
if status is-login; and command -q uwsm
    if uwsm check may-start
        exec uwsm start hyprland.desktop
    end
end

if status is-interactive
    if test -f "$XDG_CONFIG_HOME/op/plugins.sh"
        source "$XDG_CONFIG_HOME/op/plugins.sh"
    end

    if command -q starship
        starship init fish | source
    end
end

