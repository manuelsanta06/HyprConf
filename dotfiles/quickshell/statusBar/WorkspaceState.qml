import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope{
  id:root

  property var snapshot:[[],null,[]]
  readonly property var workspaces:snapshot[0]
  readonly property var currentWorkspace:snapshot[1]
  property bool refreshPending:false

  function isUrgent(workspace){
    const urgent=Hyprland.toplevels.values.filter(window=>window.urgent)
    return snapshot[2].some(window=>window.workspace.address===workspace.address&&
      urgent.some(toplevel=>toplevel.address===window.address.replace(/^0x/,"")))
  }

  // Query IDs directly: Quickshell's workspace model doesn't handle changeworkspaceid yet.
  Process{
    id:query
    command:["hyprctl","-j","--batch","workspaces;activeworkspace;clients"]
    running:true
    stdout:StdioCollector{
      onStreamFinished:{
        try{
          // hyprctl separates batch responses with three newlines.
          const values=text.trim().split("\n\n\n").map(value=>JSON.parse(value))
          if(values.length===3)root.snapshot=values
        }catch(error){console.warn("Could not read workspace state:",error)}
      }
    }
    onExited:if(root.refreshPending)refreshTimer.restart()
  }

  Timer{
    id:refreshTimer
    interval:30
    onTriggered:{
      root.refreshPending=query.running
      if(!query.running)query.running=true
    }
  }

  Connections{
    target:Hyprland
    function onRawEvent(event){
      if(/^(workspace|focusedmon|activewindow|createworkspace|destroyworkspace|moveworkspace|changeworkspaceid|movewindow|openwindow|closewindow|activespecial|fullscreen|urgent|monitor|configreloaded)/.test(event.name))
        refreshTimer.restart()
    }
  }
}
