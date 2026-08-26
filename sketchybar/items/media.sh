media=(
  script="$PLUGIN_DIR/media.sh"
  updates=on
  position=q
  padding_right=20
)

sketchybar --add item media center \
           --set media "${media[@]}" \
           --subscribe media media_change
