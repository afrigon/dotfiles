set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR
set -x SUDO_EDITOR $EDITOR
set -x VISUAL $EDITOR
set -x BROWSER firefox

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
