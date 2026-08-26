#!/bin/zsh

yabai="/opt/homebrew/bin/yabai"
if [[ "$($yabai -m config focus_follows_mouse)" == "disabled" ]]; then
    $yabai -m config focus_follows_mouse autoraise
else
    $yabai -m config focus_follows_mouse off
fi
