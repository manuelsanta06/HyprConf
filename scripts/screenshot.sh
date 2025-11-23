#!/usr/bin/env bash

grim -g "$(hyprctl clients -j | jq -r --argjson active "$(hyprctl activeworkspace -j | jq -r .id)" '.[] | select(.workspace.id == $active) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)" - | wl-copy --type image/png
