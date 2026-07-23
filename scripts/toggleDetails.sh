#!/bin/bash

BLUR_STATE=$(hyprctl getoption decoration:blur:enabled -j | jq '.bool')

if [ "$BLUR_STATE" = "true" ];then
  hyprctl eval "hl.config({
    decoration={
      shadow={enabled=false},
      blur={enabled=false},
      rounding=0
    },
    general={
      border_size=3,
      gaps_in=1,
      gaps_out=0
    },
    animations={enabled=false}
  })">/dev/null 2>&1
  echo "false"
else
  hyprctl reload>/dev/null 2>&1
  echo "true"
fi
