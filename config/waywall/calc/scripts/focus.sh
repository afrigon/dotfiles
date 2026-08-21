#!/bin/sh

if [ "$(hyprctl activewindow -j | jq -r .class)" = "waywall" ]; then
    echo true
else
    echo false
fi

while true; do
    ncat -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
        while IFS= read -r line; do
            case "$line" in
                "activewindow>>waywall,"*) echo true ;;
                "activewindow>>"*) echo false ;;
            esac
        done
    sleep 1
done
