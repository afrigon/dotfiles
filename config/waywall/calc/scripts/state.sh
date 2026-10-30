#!/bin/sh

file="$HOME/.local/share/PrismLauncher/instances/mcsr/minecraft/wpstateout.txt"
last=""

emit() {
    if [ "$1" != "$last" ]; then
        echo "$1"
        last="$1"
    fi
}

emit "$(cat "$file" 2>/dev/null)"

while inotifywait -qq -e modify -e close_write "$file" 2>/dev/null; do
    emit "$(cat "$file" 2>/dev/null)"
done

while true; do
    emit "$(cat "$file" 2>/dev/null)"
    sleep 0.2
done
