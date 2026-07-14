set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR
set -x SUDO_EDITOR $EDITOR
set -x VISUAL $EDITOR
set -x BROWSER firefox

set -x CLAUDE_CONFIG_DIR ~/.config/claude

switch (uname)
case Linux
    set -x OSTYPE "Linux"
case Darwin
    set -x OSTYPE "MacOS"
case FreeBSD NetBSD DragonFly
    set -x OSTYPE "FreeBSD"
case '*'
    set -x OSTYPE "unknown"
end
