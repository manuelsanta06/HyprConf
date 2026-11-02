
-- KEYBINDINGS

-- Variables
local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = terminal..' yazi "$(cat /tmp/scdf)"'

-- Ñ binds
hl.bind("XF86Launch2", hl.dsp.exec_cmd("wtype ñ"))
hl.bind("SHIFT + XF86Launch2", hl.dsp.exec_cmd("wtype Ñ"))

-- Scripts and Apps
hl.bind(mainMod.." + SHIFT + S", hl.dsp.exec_cmd("screenshot.sh"))
hl.bind("Print", hl.dsp.exec_cmd("screenshot.sh"))
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
hl.bind(mainMod.." + left", hl.dsp.focus({direction = "left"  }))
hl.bind(mainMod.." + right",hl.dsp.focus({direction = "right" }))
hl.bind(mainMod.." + up",   hl.dsp.focus({direction = "up"    }))
hl.bind(mainMod.." + down", hl.dsp.focus({direction = "down"  }))

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



-- workspace groups: ten shared workspaces per group, with memory per monitor
local memory={}
local activeWorkspace=hl.get_active_workspace()
local group=activeWorkspace and activeWorkspace.id>=1 and activeWorkspace.id<=100 and math.floor((activeWorkspace.id-1)/10) or 0

local function rememberMonitors(monitors)
  for _,monitor in ipairs(monitors) do
    local workspace=monitor.active_workspace
    if workspace and workspace.id>=1 and workspace.id<=100 then
      local g=math.floor((workspace.id-1)/10)
      memory[g]=memory[g] or {}

      -- keep a disconnected monitor's workspace from replacing another's memory.
      for name,id in pairs(memory[g]) do
        if id==workspace.id and name~=monitor.name and not hl.get_monitor(name) then
          workspace=nil
          break
        end
      end
      if workspace then memory[g][monitor.name]=workspace.id end
    end
  end
end

local function changeGroup(newGroup,carryWindow)
  local focused=hl.get_active_monitor()
  if not focused then return end
  -- Capture the original window before restoring workspaces changes focus.
  local window=carryWindow and hl.get_active_window()

  local monitors={}
  for _,monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror then monitors[#monitors+1]=monitor end
  end
  rememberMonitors(monitors)
  memory[newGroup]=memory[newGroup] or {}
  local targets=memory[newGroup]
  local used={}
  for _,id in pairs(targets) do used[id]=true end

  -- new monitors get a different workspace, including on the first visit.
  for _,monitor in ipairs(monitors) do
    if not targets[monitor.name] then
      for position=1,10 do
        local id=newGroup*10+position
        if not used[id] then
          targets[monitor.name]=id
          used[id]=true
          break
        end
      end
    end
  end

  group=newGroup
  for _,monitor in ipairs(monitors) do
    local id=targets[monitor.name]
    if id then
      hl.dispatch(hl.dsp.focus({monitor=monitor.name}))
      hl.dispatch(hl.dsp.focus({workspace=id,on_current_monitor=true}))
    end
  end
  hl.dispatch(hl.dsp.focus({monitor=focused.name}))
  if window and targets[focused.name] then
    hl.dispatch(hl.dsp.window.move({window=window,workspace=targets[focused.name],follow=true}))
  end
end

rememberMonitors(hl.get_monitors())

hl.bind(mainMod.." + ALT + Q",function()
  changeGroup(0,false)
end)
hl.bind(mainMod.." + ALT + SHIFT + Q",function()
  changeGroup(0,true)
end)

for i=1,10 do
  local digit=i%10  --10 maps to key 0
  local key=tostring(digit)

  hl.bind(mainMod.." + ALT + "..key,function()
    changeGroup(digit,false)
  end)

  hl.bind(mainMod.." + ALT + SHIFT + "..key,function()
    changeGroup(digit,true)
  end)

  hl.bind(mainMod.." + "..key,function()
    hl.dispatch(hl.dsp.focus({workspace=group*10+i,}))
  end)

  hl.bind(mainMod.." + SHIFT + "..key,function()
    hl.dispatch(hl.dsp.window.move({workspace=group*10+i,}))
  end)
end



-- Special workspaces
hl.bind(mainMod.." + TAB", hl.dsp.workspace.toggle_special("browser"))
hl.bind(mainMod.." + SHIFT + TAB", hl.dsp.window.move({ workspace = "special:browser" }))

hl.bind(mainMod.." + Hyper_L", hl.dsp.workspace.toggle_special("compile"))
hl.bind(mainMod.." + SHIFT + Hyper_L", hl.dsp.window.move({workspace="special:compile"}))

hl.bind(mainMod.." + grave", hl.dsp.workspace.toggle_special("games"))
hl.bind(mainMod.." + SHIFT + grave",hl.dsp.window.move({workspace="special:games"}))

-- Mouse binds
hl.bind(mainMod.." + mouse:272", hl.dsp.window.drag(),  {mouse=true})
hl.bind(mainMod.." + mouse:273", hl.dsp.window.resize(),{mouse=true})

-- Laptop multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
  {locked=true,repeating=true})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
  {locked=true,repeating=true})
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
  {locked=true,repeating=true})
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
  {locked=true,repeating=true})
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 5%+"),{locked=true,repeating=true})
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 5%-"),{locked=true,repeating=true})

-- Playerctl keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),      {locked=true})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),{locked=true})
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),{locked=true})
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),  {locked=true})
