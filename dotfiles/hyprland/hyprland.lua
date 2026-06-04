-- PROGRAMS
local terminal    ="kitty"
local fileManager =terminal .. ' yazi "$(cat /tmp/scdf)"'
local menu        ="~/.config/rofi/launcher.sh"

-- AUTOSTART
hl.on("hyprland.start",function()
  hl.exec_cmd(terminal)
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("adb start-server")
  hl.exec_cmd("bombini -d")
  hl.exec_cmd("quickshell")
  
  hl.exec_cmd('batsignal -w 25 -c 15 -f 99 -d 5 -D "systemctl suspend"')
  -- hl.exec_cmd("wl-paste --watch cliphist store")

  -- Banana cursor
  hl.exec_cmd("hyprctl setcursor Banana 48")
end)

-- External files
require("displays")
require("keybinds")

-- LOOK AND FEEL
hl.config({
  general={
    gaps_in=5,
    gaps_out=2,
    border_size=2,

    col={
      active_border="rgba(8f00ffff)",
      inactive_border="rgba(595959aa)",
    },

    resize_on_border=true,

    layout="dwindle",
  },
  decoration={
    rounding=10,
    blur={
      enabled=true,
      size=8,
      passes=1,
      noise=0.0,
      xray=true,
      special=false,
    },
    shadow={
      enabled=true,
      range=10,
      color="rgba(8f00ffaf)",
      color_inactive=0,
    }
  },
  animations={
    enabled=true,
  }
})

-- Animations

hl.curve("niercurve",{type="bezier",points={{0.4,0},{0.2,1}}})
hl.animation({leaf = "windows",    enabled = true,  speed = 3, bezier = "niercurve", style = "slide" })
hl.animation({leaf = "windowsOut", enabled = true,  speed = 2, bezier = "niercurve", style = "slide" })

-- hl.animation({leaf = "border",      speed = 10, bezier = "default" })
-- hl.animation({leaf = "borderangle", speed = 8,  bezier = "default" })
-- hl.animation({leaf = "fade",       enabled = true,  speed = 5,  bezier = "default" })

hl.animation({leaf = "workspaces", enabled = true,  speed = 6,  bezier = "default" })


hl.config({
  dwindle={
    preserve_split=true
  },
  master={
    new_status="slave",
  }
})

hl.config({
  misc={
    force_default_wallpaper=0,
    animate_manual_resizes=true,
    on_focus_under_fullscreen=2,
  }
})


-- INPUT
hl.config({
  input = {
    kb_layout  = "",
    kb_variant = "",
    kb_model   = "",
    kb_options = "caps:hyper",
    kb_rules   = "",

    follow_mouse = 1,

    accel_profile = "flat",

    touchpad = {
      natural_scroll = false,
    },
  },
})

-- DEVICES
hl.device({
    name          = "elan0788:00-04f3:321a-touchpad",
    accel_profile = "adaptive",
})

hl.gesture({
    fingers=3,
    direction="horizontal",
    action="workspace"
})

-- WINDOWS AND WORKSPACES

hl.workspace_rule({workspace="w[tv1]",gaps_out=0,gaps_in=0})
-- hl.workspace_rule({workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name        = "no-gaps-wtv1",
    match       = {workspace="w[tv1]",float=false},
    border_size = 0,
    rounding    = 0,
})

-- Ignorar eventos maximize
hl.window_rule({
    name          = "suppress-maximize-events",
    match         = {class=".*"},
    suppress_event= "maximize",
})

-- Picture-in-Picture
hl.window_rule({
    name  = "picture-in-picture",
    match = {title="(.*)(Picture-in-Picture)(.*)"},
    float = true,
    pin   = true,
    move  = "(monitor_w-window_w) 0",
    size  = "monitor_w*0.3 monitor_h*0.3",
})

-- dragon-drop
hl.window_rule({
    name  = "dragon-drop",
    match = {class="dragon-drop"},
    float = true,
    pin   = true,
})

-- kitty-monitor
hl.window_rule({
    name        = "kitty-monitor",
    match       = {class="kitty-monitor"},
    float       = true,
    pin         = true,
    move        = "0 0",
    size        = "monitor_w*0.27 monitor_h*0.25",
    border_size = 0,
    no_blur     = true,
    opacity     = "1.0 override 1.0 override",
})

-- pinentry
hl.window_rule({
    name         = "pinentry",
    match        = {class="(pinentry-)(.*)"},
    stay_focused = true,
})
