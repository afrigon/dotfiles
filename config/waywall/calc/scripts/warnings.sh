#!/bin/sh

filter='{messages: (.informationMessages
    | map(select(.severity != "INFO"))
    | map({severity, type: (.type | ascii_downcase | gsub("_"; " "))}))}'

while true; do
    curl -s --max-time 2 "http://[::1]:52533/api/v1/information-messages" | jq -c "$filter"
    curl -sN "http://[::1]:52533/api/v1/information-messages/events" |
        sed -u -n 's/^data: //p' |
        jq -c --unbuffered "$filter"
    sleep 1
done
