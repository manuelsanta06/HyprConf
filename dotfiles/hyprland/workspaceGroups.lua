-- workspace groups: ten shared workspaces per group, with memory per monitor
return function(config)
  local mainMod=config.mainMod

  local memory={}
  local activeWorkspace=hl.get_active_workspace()
  local group=activeWorkspace and activeWorkspace.id>=1 and activeWorkspace.id<=100 and math.floor((activeWorkspace.id-1)/10) or 0

  local function publishGroup()
    local runtimeDir=os.getenv("XDG_RUNTIME_DIR")
    if not runtimeDir then return end
    local path=runtimeDir.."/workspace-group"
    local file=assert(io.open(path..".tmp","w"))
    assert(file:write(group,"\n"))
    assert(file:close())
    assert(os.rename(path..".tmp",path))
  end

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

    hl.animation(config.groupAnimation)
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
    publishGroup()
  end

  local function changeWorkspace(position,carryWindow)
    hl.animation(config.workspaceAnimation)
    local workspace=group*10+position
    if carryWindow then
      hl.dispatch(hl.dsp.window.move({workspace=workspace}))
    else
      hl.dispatch(hl.dsp.focus({workspace=workspace}))
    end
  end

  rememberMonitors(hl.get_monitors())
  publishGroup()


  -- Special workspaces
  hl.bind(mainMod.." + TAB", hl.dsp.workspace.toggle_special("browser"))
  hl.bind(mainMod.." + SHIFT + TAB", hl.dsp.window.move({ workspace = "special:browser" }))

  hl.bind(mainMod.." + Hyper_L", hl.dsp.workspace.toggle_special("compile"))
  hl.bind(mainMod.." + SHIFT + Hyper_L", hl.dsp.window.move({workspace="special:compile"}))

  hl.bind(mainMod.." + grave", hl.dsp.workspace.toggle_special("games"))
  hl.bind(mainMod.." + SHIFT + grave",hl.dsp.window.move({workspace="special:games"}))

  --
  -- workspaces and groups
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
      changeWorkspace(i,false)
    end)

    hl.bind(mainMod.." + SHIFT + "..key,function()
      changeWorkspace(i,true)
    end)
  end

  return{changeGroup=changeGroup,changeWorkspace=changeWorkspace}
end
