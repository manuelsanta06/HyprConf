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
    systemctl hibernate
    ;;
  "4")
    #POWER PROFILES HERE
    PROFILES=("power-saver" "balanced" "performance")
    CURRENT_PROFILE=$(powerprofilesctl get)
    for i in "${!PROFILES[@]}"; do
        if [[ "${PROFILES[$i]}" == "$CURRENT_PROFILE" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done
    NEXT_PROFILE="${PROFILES[$(((CURRENT_INDEX+1)%${#PROFILES[@]}))]}"

    powerprofilesctl set "$NEXT_PROFILE"
    ;;
  "5")
    systemctl reboot --boot-loader-entry=auto-windows
    ;;
  *)
    echo 0 > /tmp/powerCounter.txt
esac
