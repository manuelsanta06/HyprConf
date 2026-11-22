pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton{
  id:root

  property var snapshot:[[],null,[],[]]
  readonly property var workspaces:snapshot[0]
  readonly property var currentWorkspace:snapshot[1]
  readonly property var monitors:snapshot[3]
  property int currentGroup:0
  property int revision:0

  function refresh(){
    revision++
    refreshTimer.restart()
  }

  FileView{
    path:Quickshell.env("XDG_RUNTIME_DIR")+"/workspace-group"
    watchChanges:true
    printErrors:false
    onFileChanged:reload()
    onLoaded:updateGroup()
    onTextChanged:updateGroup()

    function updateGroup(){
      const value=text().trim()
      if(/^[0-9]$/.test(value))root.currentGroup=Number(value)
    }
  }

  function isUrgent(workspace){
    const urgent=Hyprland.toplevels.values.filter(window=>window.urgent)
    return snapshot[2].some(window=>window.workspace.address===workspace.address&&
      urgent.some(toplevel=>toplevel.address===window.address.replace(/^0x/,"")))
  }

  // Query IDs directly: Quickshell's workspace model doesn't handle changeworkspaceid yet.
  Process{
    id:query
    property int revision:0
    command:["hyprctl","-j","--batch","workspaces;activeworkspace;clients;monitors"]
    running:true
    stdout:StdioCollector{
      onStreamFinished:{
        try{
          // hyprctl separates batch responses with three newlines.
          const values=text.trim().split("\n\n\n").map(value=>JSON.parse(value))
          if(values.length===4&&query.revision===root.revision)root.snapshot=values
        }catch(error){console.warn("Could not read workspace state:",error)}
      }
    }
    onExited:if(query.revision!==root.revision)refreshTimer.restart()
  }

  Timer{
    id:refreshTimer
    interval:30
    onTriggered:{
      if(!query.running){
        query.revision=root.revision
        query.running=true
      }
    }
  }

  Connections{
    target:Hyprland
    function onRawEvent(event){
      if(/^(workspace|focusedmon|activewindow|createworkspace|destroyworkspace|moveworkspace|changeworkspaceid|movewindow|openwindow|closewindow|activespecial|fullscreen|urgent|monitor|configreloaded)/.test(event.name))
        root.refresh()
    }
  }
}
