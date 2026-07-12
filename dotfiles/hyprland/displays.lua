
-- MONITORS

-- USB-C
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "auto-left",
    scale    = 1
})

-- Notebook
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1
})

-- Samsung TV
hl.monitor({
    output   = "desc:Samsung Electric Company SAMSUNG 0x01000E00",
    mode     = "2560x1440@59",
    position = "auto-up",
    scale    = 1
})

-- Fallback
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1
})
