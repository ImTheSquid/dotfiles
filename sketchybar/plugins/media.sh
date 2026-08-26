#!/bin/bash
STATE="$(echo "$INFO" | jq -r '.state')"

truncate_text() {
  local text="$1"
  local max_length="$2"
  
  if [ "${#text}" -le "$max_length" ]; then
    echo "$text"
  else
    local truncated_length=$((max_length - 3))
    echo "${text:0:truncated_length}..."
  fi
}

if [ "$STATE" = "playing" ]; then
  TITLE="$(echo "$INFO" | jq -r '.title')"
  APP="$(echo "$INFO" | jq -r '.app')"
  ARTIST="$(echo "$INFO" | jq -r '.artist')"
  sketchybar --set $NAME label="$APP: $(truncate_text "$TITLE" 30) - $ARTIST" drawing=on
else
  sketchybar --set $NAME drawing=off
fi

