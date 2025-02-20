val=$(cat /tmp/powerCounter.txt)
if [ "$val" == "" ]; then
    val=0
    echo 0 > /tmp/powerCounter.txt
fi

case "$val" in
    "0")
        swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 $(ls /home/santa/resources/wallpapers/$((1+$RANDOM%$(ls -1q /home/santa/resources/wallpapers/ | wc -l))).* | head -n 1)
        ;;
    "1")
        systemctl poweroff
        ;;
    "2")
        reboot
        ;;
    "3")
        systemctl suspend
        ;;
    *)
        echo 0 > /tmp/powerCounter.txt
esac
