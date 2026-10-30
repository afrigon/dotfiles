#!/bin/sh

dir="$(cd "$(dirname "$0")/.." && pwd)"

WAYLAND_DISPLAY="$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')"
export WAYLAND_DISPLAY

(
    sleep 1
    eww --config "$dir" open f3line 2>/dev/null
) &

exec eww --config "$dir" daemon --no-daemonize
