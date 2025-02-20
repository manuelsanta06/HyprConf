status=$(playerctl status 2>/dev/null)
if [ -n "$status" ] && [ "$status" != "Stopped" ]; then
    echo '{"text":"󰒭","tooltip":"Next","class":"media"}'
else
    echo '{"text":"","tooltip":"Next","class":"media"}'
fi
