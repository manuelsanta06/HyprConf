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

  local function swapDirectories(first,second)
    local pipe=assert(io.popen("scd-path --swap "..first.." "..second.." 2>&1; printf '\\n%d' $?","r"))
    local output=assert(pipe:read("*a"))
    pipe:close() -- Hyprland may reap the child before Lua can collect its exit status.
    local message,status=output:match("^(.*)\n(%d+)$")
    assert(status=="0","Could not swap group directories: "..(message or output))
  end

  local function swapGroups(newGroup)
    if newGroup==group then return end
    assert(type(newGroup)=="number" and newGroup%1==0 and newGroup>=0 and newGroup<=9,"Invalid group")
    rememberMonitors(hl.get_monitors())

    local workspaces=hl.get_workspaces()
    local used,moves={},{}
    for _,workspace in ipairs(workspaces) do
      if workspace.id then used[workspace.id]=true end
    end
    local temporary=101
    for _,workspace in ipairs(workspaces) do
      local id=workspace.id
      if id and id>=1 and id<=100 then
        local g=math.floor((id-1)/10)
        if g==group or g==newGroup then
          while used[temporary] do temporary=temporary+1 end
          local destination=g==group and newGroup or group
          moves[#moves+1]={workspace=workspace,id=id,target=destination*10+(id-1)%10+1,temporary=temporary}
          used[temporary]=true
        end
      end
    end

    -- Keep scd's storage details in scd-path; abort before changing IDs if it fails.
    swapDirectories(group,newGroup)
    local function changeID(move,id)
      if move.workspace.id==id then return end
      local result=hl.dispatch(hl.dsp.workspace.change_id({workspace=move.workspace,id=id}))
      assert(result.ok,"Could not change workspace ID")
    end
    local ok,err=pcall(function()
      -- Vacate both ranges first, including existing empty workspaces.
      for _,move in ipairs(moves) do changeID(move,move.temporary) end
      for _,move in ipairs(moves) do changeID(move,move.target) end
    end)
    if not ok then
      for _,move in ipairs(moves) do changeID(move,move.temporary) end
      for _,move in ipairs(moves) do changeID(move,move.id) end
      swapDirectories(group,newGroup)
      error(err)
    end

    memory[group],memory[newGroup]=memory[newGroup],memory[group]
    for _,g in ipairs({group,newGroup}) do
      for name,id in pairs(memory[g] or {}) do
        memory[g][name]=g*10+(id-1)%10+1
      end
    end
    group=newGroup
    publishGroup()
  end

  local function swapWorkspaces()
    local monitors=hl.get_monitors()
    if #monitors~=2 then return end
    local first,second=monitors[1],monitors[2]
    local firstWorkspace,secondWorkspace=first.active_workspace,second.active_workspace
    if not firstWorkspace or not secondWorkspace then return end
    local focused=hl.get_active_monitor()
    local firstSpecial,secondSpecial=first.active_special_workspace,second.active_special_workspace
    rememberMonitors(monitors)

    -- Capture destinations before moving anything, so no workspace moves twice.
    local moves={}
    for _,workspace in ipairs(hl.get_workspaces()) do
      if workspace~=firstWorkspace and workspace~=secondWorkspace then
        local target=workspace.monitor==first and second or workspace.monitor==second and first
        if target then moves[#moves+1]={workspace=workspace,monitor=target} end
      end
    end

    if firstSpecial then first:set_special_workspace(nil) end
    if secondSpecial then second:set_special_workspace(nil) end
    hl.dispatch(hl.dsp.workspace.swap_monitors({monitor1=first,monitor2=second}))
    for _,move in ipairs(moves) do
      hl.dispatch(hl.dsp.workspace.move(move))
    end
    if secondSpecial then first:set_special_workspace(secondSpecial) end
    if firstSpecial then second:set_special_workspace(firstSpecial) end

    for _,targets in pairs(memory) do
      targets[first.name],targets[second.name]=targets[second.name],targets[first.name]
    end
    if focused then hl.dispatch(hl.dsp.focus({monitor=focused})) end
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

  -- workspaces and groups
  hl.bind(mainMod.." + ALT + S",swapWorkspaces)
  hl.bind(mainMod.." + ALT + R",hl.dsp.submap("swap-group"))
  hl.define_submap("swap-group",function()
    hl.bind("Escape",hl.dsp.submap("reset"),{ignore_mods=true})
    for digit=0,9 do
      hl.bind(tostring(digit),function()
        hl.dispatch(hl.dsp.submap("reset"))
        swapGroups(digit)
      end,{ignore_mods=true})
    end
  end)
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

  return{changeGroup=changeGroup,changeWorkspace=changeWorkspace,swapGroups=swapGroups,swapWorkspaces=swapWorkspaces}
end
