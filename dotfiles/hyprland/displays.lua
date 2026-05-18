
-- MONITORS

-- USB-C
hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "-1920x0",
    scale    = 1
})

-- Notebook
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1
})

-- Any other
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1
})
