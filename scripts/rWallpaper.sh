#!/bin/bash

WCOUNT="$(ls -1q ~/resources/wallpapers/ | wc -l)"
FOCUSED_OUTPUT=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
[ ! -z $1 ] && 
  WALLPAPER_DIR=$(ls ~/resources/wallpapers/$1.* | head -n 1) ||
  WALLPAPER_DIR=$(ls ~/resources/wallpapers/$((1+$RANDOM%$WCOUNT)).* | head -n 1)

swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 "$WALLPAPER_DIR" -o "$FOCUSED_OUTPUT"
