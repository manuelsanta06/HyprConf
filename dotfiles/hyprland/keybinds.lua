
-- KEYBINDINGS

-- Variables
local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = terminal..' yazi "$(cat /tmp/scdf)"'
local menu        = "~/.config/rofi/launcher.sh"

-- Ñ binds
hl.bind("XF86Launch2", hl.dsp.exec_cmd("wtype ñ"))
hl.bind("SHIFT + XF86Launch2", hl.dsp.exec_cmd("wtype Ñ"))

-- Scripts and Apps
hl.bind(mainMod.." + SHIFT + S", hl.dsp.exec_cmd("screenshot.sh"))
hl.bind(mainMod.." + F2", hl.dsp.exec_cmd("rWallpaper.sh"))

hl.bind(mainMod.." + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod.." + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod.." + W", hl.dsp.exec_cmd(terminal..' -d "$(cat /tmp/scdf)"'))

hl.bind(mainMod.." + SPACE", hl.dsp.global("quickshell:launcher"))

hl.bind(mainMod.." + B", hl.dsp.exec_cmd('kitty --class "kitty-monitor" -o background_opacity=0.5 -e btop -l -p 2'))

-- Window management
hl.bind(mainMod.." + C",hl.dsp.window.close())
hl.bind(mainMod.." + M",hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod.." + V",hl.dsp.window.float({action="toggle"}))
hl.bind(mainMod.." + P",hl.dsp.window.pin({action="toggle"}))
hl.bind(mainMod.." + K",hl.dsp.window.pseudo())
hl.bind(mainMod.." + F",hl.dsp.window.fullscreen({action="toggle"}))
hl.bind(mainMod.." + J",hl.dsp.layout("togglesplit"))

-- Move focus
hl.bind(mainMod.." + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod.." + right",hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod.." + up",   hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod.." + down", hl.dsp.focus({ direction = "down" }))

-- Swap windows
hl.bind(mainMod.." + CONTROL + left", hl.dsp.window.swap({direction="l"}))
hl.bind(mainMod.." + CONTROL + right",hl.dsp.window.swap({direction="r"}))
hl.bind(mainMod.." + CONTROL + up",   hl.dsp.window.swap({direction="u"}))
hl.bind(mainMod.." + CONTROL + down", hl.dsp.window.swap({direction="d"}))

-- Move windows
hl.bind(mainMod.." + SHIFT + left", hl.dsp.window.move({direction="l"}))
hl.bind(mainMod.." + SHIFT + right",hl.dsp.window.move({direction="r"}))
hl.bind(mainMod.." + SHIFT + up",   hl.dsp.window.move({direction="u"}))
hl.bind(mainMod.." + SHIFT + down", hl.dsp.window.move({direction="d"}))

-- Resize active
hl.bind(mainMod.." + ALT + left", hl.dsp.window.resize({x=-10,y = 0, relative=true}),{repeating=true})
hl.bind(mainMod.." + ALT + right",hl.dsp.window.resize({x= 10,y = 0, relative=true}),{repeating=true})
hl.bind(mainMod.." + ALT + up",   hl.dsp.window.resize({x= 0, y =-10,relative=true}),{repeating=true})
hl.bind(mainMod.." + ALT + down", hl.dsp.window.resize({x= 0, y = 10,relative=true}),{repeating=true})

-- Switch workspaces & Move active window to a workspace (1-10)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod.." + "..key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod.." + SHIFT + "..key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspaces
hl.bind(mainMod.." + TAB", hl.dsp.workspace.toggle_special("browser"))
hl.bind(mainMod.." + SHIFT + TAB", hl.dsp.window.move({ workspace = "special:browser" }))

hl.bind(mainMod.." + Hyper_L", hl.dsp.workspace.toggle_special("compile"))
hl.bind(mainMod.." + SHIFT + Hyper_L", hl.dsp.window.move({ workspace = "special:compile" }))

hl.bind(mainMod.." + grave", hl.dsp.workspace.toggle_special("games"))
hl.bind(mainMod.." + SHIFT + grave", hl.dsp.window.move({ workspace = "special:games" }))

-- Mouse binds
hl.bind(mainMod.." + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod.." + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Playerctl keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),      {locked=true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),{locked=true})
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),{locked=true})
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),  {locked=true})
