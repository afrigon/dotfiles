#!/bin/sh

filter='{
    type: .resultType,
    throws: (.eyeThrows | length),
    correction: (.eyeThrows[-1].correction // 0),
    correctionIncrements: (.eyeThrows[-1].correctionIncrements // 0),
    predictions: (.predictions[:2] | map({
        nx: (.chunkX * 2),
        nz: (.chunkZ * 2),
        certainty,
        distance: (.overworldDistance | floor),
        netherDistance: ((.overworldDistance | floor) / 8 | floor)
    }))
}'

while true; do
    curl -s --max-time 2 "http://[::1]:52533/api/v1/stronghold" | jq -c "$filter"
    curl -sN http://[::1]:52533/api/v1/stronghold/events |
        sed -u -n 's/^data: //p' |
        jq -c --unbuffered "$filter"
    sleep 1
done
