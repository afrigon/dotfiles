#!/bin/sh

description=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ | sed -n 's/.*node\.description = "\(.*\)"/\1/p')
service=$(systemctl --user is-active scarlet.service)

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    icon="󰍭"
else
    icon="󰍬"
fi

printf '{"text": "%s", "tooltip": "Input: %s\\nScarlet service: %s"}\n' "$icon" "$description" "$service"
