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
        systemctl reboot --boot-loader-entry=auto-windows
        ;;
    "2")
        systemctl poweroff
        ;;
    "3")
        reboot
        ;;
    "4")
        systemctl suspend
        ;;
    *)
        echo 0 > /tmp/powerCounter.txt
esac
