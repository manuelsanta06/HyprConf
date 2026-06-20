#!/bin/bash

WALLPAPERS_DIR="$HOME/resources/wallpapers"
FOCUSED_OUTPUT=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

if [[ -n "$1" ]];then
  WALLPAPER=$(find "$WALLPAPERS_DIR" -maxdepth 1 -type f -name "$1.*" | head -n 1)
  
  if [[ -z "$WALLPAPER" ]];then
    echo "Error: No such file '$1'"
    exit 1
  fi
else
  WALLPAPER=$(find "$WALLPAPERS_DIR" -maxdepth 1 -type f | shuf -n 1)
fi

awww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 "$WALLPAPER" -o "$FOCUSED_OUTPUT"
