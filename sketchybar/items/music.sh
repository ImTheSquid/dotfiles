# Add event
sketchybar -m --add event song_update com.apple.iTunes.playerInfo

# Add Music Item
sketchybar -m --add item music center                        \
    --set music script="~/.config/sketchybar/scripts/music"  \
    icon.padding_left=10                                     \
    drawing=off                                              \
    position=e                                               \
    --subscribe music song_update
    # click_script="~/.config/sketchybar/scripts/music_click"  \
