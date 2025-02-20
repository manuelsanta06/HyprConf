val=$(cat /tmp/powerCounter.txt)
if [ "$val" == "" ]; then
    val=0
    echo 0 > /tmp/powerCounter.txt
fi

case "$val" in
    "0")
        echo '{"text":"","tooltip":"Power menu","on-click-right":"echo hola","class":"arch"}'
        ;;
    "1")
        echo '{"text":"","tooltip":"  shutdown","on-click-right":"echo hola","class":"off"}'
        ;;
    "2")
        echo '{"text":"","tooltip":"  reboot","on-click-right":"reboot","class":"reboot"}'
        ;;
    "3")
        echo '{"text":"","tooltip":"  hibernate","on-click-right":"systemctl suspend","class":"hiber"}'
        ;;
    *)
        echo 0 > /tmp/powerCounter.txt
        echo '{"text":"","tooltip":"Power menu","on-click-right":"bash","class":"arch"}'
esac
