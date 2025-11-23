val=$(cat /tmp/powerCounter.txt)
if [ "$val" == "" ]; then
    val=0
    echo 0 > /tmp/powerCounter.txt
fi

case "$val" in
    "0")
        rWallpaper.sh
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
