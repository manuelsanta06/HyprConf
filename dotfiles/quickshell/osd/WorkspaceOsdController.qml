import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

Scope{
  id:root

  property var previousMonitors:({})
  property var pendingAction:null
  property bool ready:false
  property bool selecting:false
  property string promptMonitor:""

  signal showRequested(string monitor,string workspace,string caption,int slot,bool persistent)
  signal hideRequested(string monitor)

  function effectiveWorkspace(monitor){
    return monitor.specialWorkspace&&monitor.specialWorkspace.name
      ?monitor.specialWorkspace:monitor.activeWorkspace
  }

  function present(monitor,action){
    const workspace=effectiveWorkspace(monitor)
    if(!workspace||!workspace.name)return
    const numbered=Number.isInteger(workspace.id)&&workspace.id>=1
    const special=workspace.type==="special"||workspace.name.startsWith("special:")
    let caption=special?"ESPECIAL":"WORKSPACE"
    if(action){
      if(action.kind==="group")caption="GRUPO "+action.to
      else if(action.kind==="swap")caption="GRUPOS "+action.from+" ↔ "+action.to
      else if(action.kind==="monitors")caption="PANTALLAS ↔"
    }
    showRequested(monitor.name,numbered?String(workspace.id):workspace.name.replace(/^special:/,""),
      caption,numbered&&workspace.id<=100?(workspace.id-1)%10:-1,false)
  }

  function update(){
    const next={}
    for(const monitor of WorkspaceState.monitors){
      const workspace=effectiveWorkspace(monitor)
      next[monitor.name]=workspace?workspace.address||workspace.name:""
      if(pendingAction||(ready&&!selecting&&previousMonitors[monitor.name]&&
        previousMonitors[monitor.name]!==next[monitor.name]))present(monitor,pendingAction)
    }
    previousMonitors=next
    pendingAction=null
    ready=true
  }

  function handleEvent(name,data){
    if(name==="submap"){
      if(data==="swap-group"){
        selecting=true
        modeExit.stop()
        const focused=WorkspaceState.monitors.find(monitor=>monitor.focused)
        promptMonitor=Hyprland.focusedMonitor?Hyprland.focusedMonitor.name:(focused?focused.name:"")
        hideRequested("")
        showRequested(promptMonitor,String(WorkspaceState.currentGroup),"INTERCAMBIAR",WorkspaceState.currentGroup,true)
      }else if(selecting){
        selecting=false
        modeExit.restart()
      }
    }else if(name==="custom"){
      const parts=data.split(",")
      if(parts[0]!=="workspace-osd"||!["group","swap","monitors"].includes(parts[1]))return
      pendingAction={kind:parts[1],from:Number(parts[2]),to:Number(parts[3])}
      selecting=false
      modeExit.stop()
      WorkspaceState.refresh()
    }else if(name==="configreloaded"){
      selecting=false
      pendingAction=null
      ready=false
      modeExit.stop()
      hideRequested("")
    }
  }

  Timer{
    id:modeExit
    interval:60
    onTriggered:if(!root.selecting&&!root.pendingAction)root.hideRequested(root.promptMonitor)
  }

  Connections{
    target:WorkspaceState
    function onSnapshotChanged(){root.update()}
  }
  Connections{
    target:Hyprland
    function onRawEvent(event){root.handleEvent(event.name,event.data)}
  }
  Component.onCompleted:if(WorkspaceState.monitors.length>0)update()
}
