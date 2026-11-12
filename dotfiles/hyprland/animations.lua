
return function(config)
  config.workspaceAnimation={leaf="workspaces",enabled=true,speed=6,bezier="default",style="slide"}
  config.groupAnimation={leaf="workspaces",enabled=true,speed=6,bezier="default",style="slidevert"}


  hl.curve("niercurve",{type="bezier",points={{0.4,0},{0.2,1}}})
  hl.animation({leaf = "windows",    enabled = true,  speed = 3, bezier = "niercurve", style = "slide" })
  hl.animation({leaf = "windowsOut", enabled = true,  speed = 2, bezier = "niercurve", style = "slide" })

  -- hl.animation({leaf = "border",      speed = 10, bezier = "default" })
  -- hl.animation({leaf = "borderangle", speed = 8,  bezier = "default" })
  -- hl.animation({leaf = "fade",       enabled = true,  speed = 5,  bezier = "default" })

  hl.animation(config.workspaceAnimation)
  hl.animation({leaf="specialWorkspace",enabled=config.workspaceAnimation.enabled,
    speed=config.workspaceAnimation.speed,bezier=config.workspaceAnimation.bezier,
    style=config.workspaceAnimation.style})
end
