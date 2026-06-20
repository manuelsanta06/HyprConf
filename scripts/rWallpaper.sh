#!/bin/bash

BASE_DIR="$HOME/resources/wallpapers"
FOCUSED_OUTPUT=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
FULL_PATH="$BASE_DIR/$1"

get_random_image(){
  find "$1" -type f | grep -iE '\.(jpg|jpeg|png|webp|gif)$' | shuf -n 1
}

if [[ -z "$1" ]]; then
  WALLPAPER=$(get_random_image "$BASE_DIR")

elif [[ -d "$FULL_PATH" ]]; then
  WALLPAPER=$(get_random_image "$FULL_PATH")

elif [[ -f "$FULL_PATH" ]]; then
  WALLPAPER="$FULL_PATH"

else
  WALLPAPER=$(find "$BASE_DIR" -type f -path "$FULL_PATH.*" | grep -iE '\.(jpg|jpeg|png|webp|gif)$' | head -n 1)

  if [[ -z "$WALLPAPER" ]]; then
    echo "Error: No such file or dirctory '$1'." >&2
    exit 1
  fi
fi

awww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 "$WALLPAPER" -o "$FOCUSED_OUTPUT"
