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
    echo '{"text":"","tooltip":"  shutdown","class":"off"}'
    ;;
  "2")
    echo '{"text":"","tooltip":"  reboot","class":"reboot"}'
    ;;
  "3")
    echo '{"text":"","tooltip":"  hibernate","class":"hiber"}'
    ;;
  "4")
    case "$(powerprofilesctl get)" in
      "performance")
        powerIcon=""
        powerClass="high"
      ;;
      "balanced")
        powerIcon=""
        powerClass="mid"
      ;;
      "power-saver")
        powerIcon=""
        powerClass="low"
      ;;
      *)
        powerIcon="?"
        powerClass="def"
      ;;
    esac
    echo '{"text":"'"$powerIcon"'","tooltip":"󱐋 Power options","class":"power-'"$powerClass"'"}'
    ;;
  "5")
    echo '{"text":"","tooltip":"  reboot to windows","class":"windows"}'
    ;;
  *)
    echo 0 > /tmp/powerCounter.txt
    echo '{"text":"","tooltip":"Power menu","class":"arch"}'
esac
