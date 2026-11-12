local config={
  mainMod     = "SUPER",
  terminal    = "kitty",
  workspaceAnimation={},
  groupAnimation={},
}
config.fileManager=config.terminal .. ' yazi "$(scd-path)"'


-- External files
require("displays")(config)
require("keybinds")(config)
require("animations")(config)
require("workspaceGroups")(config)


-- AUTOSTART
hl.on("hyprland.start",function()
  hl.exec_cmd(config.terminal)
  hl.exec_cmd("[workspace special:browser silent] /opt/zen-browser/zen")

  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("adb start-server")
  hl.exec_cmd("bombini -T \"kitty -e\" -d")
  hl.exec_cmd("quickshell")
  
  hl.exec_cmd('batsignal -w 25 -c 15 -d 5 -D "systemctl suspend"')
  -- hl.exec_cmd("wl-paste --watch cliphist store")

  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user start hyprland-session.target")

  hl.exec_cmd("/usr/lib/pentablet/PenTablet.sh /mini")

  -- Banana cursor
  hl.exec_cmd("hyprctl setcursor Banana 48")
end)


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
      brightness=1.0,
      noise=0.0,
      xray=true,

      size=10,
      passes=1,

      special=false,

      variant="kawase",
    },
    shadow={
      enabled=true,
      range=10,
      color="rgba(8f00ffaf)",
      color_inactive=0,
    }
  },
  animations={enabled=true}
})


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

    follow_mouse=1,

    accel_profile="flat",

    touchpad={
      natural_scroll=false,
    },
  },
})

-- DEVICES
hl.device({
    name          = "elan0788:00-04f3:321a-touchpad",
    accel_profile = "adaptive",
})

-- WINDOWS AND WORKSPACES

hl.workspace_rule({workspace="w[tv1]",gaps_out=0,gaps_in=0})
hl.window_rule({
    name        = "no-gaps-wtv1",
    match       = {workspace="w[tv1]",float=false},
    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name          = "suppress-maximize-events",
    match         = {class=".*"},
    suppress_event= "maximize",
})

hl.window_rule({
    name  = "windowkill-no-xray",
    match = {class="windowkill"},
    xray  = false,
})

hl.window_rule({
    name  = "picture-in-picture",
    match = {title="(.*)(Picture-in-Picture)(.*)"},
    float = true,
    pin   = true,
    move  = "(monitor_w-window_w) 0",
    size  = "monitor_w*0.3 monitor_h*0.3",
})

hl.window_rule({
    name  = "dragon-drop",
    match = {class="dragon-drop"},
    float = true,
    pin   = true,
})

hl.window_rule({
    name        = "terminal-monitor",
    match       = {class="terminal-monitor"},
    float       = true,
    pin         = true,
    move        = "0 0",
    size        = "monitor_w*0.27 monitor_h*0.25",
    border_size = 0,
    no_blur     = true,
    opacity     = "1.0 override 1.0 override",
})

hl.window_rule({
    name         = "pinentry",
    match        = {class="(pinentry-)(.*)"},
    stay_focused = true,
})

hl.layer_rule({
  name="statusbar-blur",
  match={namespace="^statusbar$"},
  blur=true,
  -- xray=true,
})
