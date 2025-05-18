#!/bin/bash

WCOUNT="$(ls -1q /home/santa/resources/wallpapers/ | wc -l)"

if [ ! -z $1 ]; then
    swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 $(ls /home/santa/resources/wallpapers/$1.* | head -n 1)
else
    swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 $(ls /home/santa/resources/wallpapers/$((1+$RANDOM%$WCOUNT)).* | head -n 1)
fi
