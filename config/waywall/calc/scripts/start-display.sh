#!/bin/sh

dir="$(cd "$(dirname "$0")/.." && pwd)"

(
    sleep 1
    eww --config "$dir" open calc 2>/dev/null
    eww --config "$dir" open boat 2>/dev/null
    eww --config "$dir" open f3line 2>/dev/null
) &

exec eww --config "$dir" daemon --no-daemonize
