#!/bin/sh

dir="$(cd "$(dirname "$0")/.." && pwd)"
out="$dir/obs/state.json"
state_file="$HOME/.local/share/PrismLauncher/instances/mcsr/minecraft/wpstateout.txt"

last=""
while true; do
    active="$(hyprctl activewindow -j 2>/dev/null | jq -r .class 2>/dev/null)"
    game="$(cat "$state_file" 2>/dev/null)"

    if [ "$active" = "waywall" ] && [ "$game" = "inworld,unpaused" ]; then
        want='{"visible": true}'
    else
        want='{"visible": false}'
    fi

    if [ "$want" != "$last" ]; then
        printf '%s' "$want" > "$out.tmp" && mv "$out.tmp" "$out"
        last="$want"
    fi

    sleep 0.25
done
