#!/bin/sh

filter='{state: .boatState}'

while true; do
    curl -s --max-time 2 "http://[::1]:52533/api/v1/boat" | jq -c "$filter"
    curl -sN "http://[::1]:52533/api/v1/boat/events" |
        sed -u -n 's/^data: //p' |
        jq -c --unbuffered "$filter"
    sleep 1
done
