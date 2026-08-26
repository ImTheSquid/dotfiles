#!/bin/zsh

if [[ "$(mullvad status --json | jq -r '.state')" == "connected" ]]; then
    DRAW=yes
else
    DRAW=no
fi

sketchybar --set "$NAME" drawing=$DRAW
