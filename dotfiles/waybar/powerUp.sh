val=$(cat /tmp/powerCounter.txt)
if [ "$val" == "" ]; then
    val=0
    echo 0 > /tmp/powerCounter.txt
fi

case "$val" in
    "0")
        echo '{"text":"","tooltip":"Power menu","class":"arch"}'
        ;;
    "1")
        echo '{"text":"","tooltip":"  reboot to windows","class":"windows"}'
        ;;
    "2")
        echo '{"text":"","tooltip":"  shutdown","class":"off"}'
        ;;
    "3")
        echo '{"text":"","tooltip":"  reboot","class":"reboot"}'
        ;;
    "4")
        echo '{"text":"","tooltip":"  hibernate","class":"hiber"}'
        ;;
    *)
        echo 0 > /tmp/powerCounter.txt
        echo '{"text":"","tooltip":"Power menu","class":"arch"}'
esac
