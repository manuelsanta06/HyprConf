status=$(playerctl status 2>/dev/null)
if [ -n "$status" ] && [ "$status" != "Stopped" ]; then
    echo '{"text":"󰒮","tooltip":"Prev","class":"media"}'
else
    echo '{"text":"","tooltip":"Prev","class":"media"}'
fi
