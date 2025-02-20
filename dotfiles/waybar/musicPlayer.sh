#!/bin/bash

song=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
song=$(jq -R <<< "$song")

echo "{\"text\":$song,\"tooltip\":\"Play/Pause\",\"class\":\"media\"}"
