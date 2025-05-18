#!/bin/bash

song=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null)
#song=$(jq -R <<< "$song")
song=$(jq -Rn --arg song "$song" '$song | gsub("&"; "&amp;")')

echo "{\"text\":$song,\"tooltip\":\"Play/Pause\",\"class\":\"media\"}"
