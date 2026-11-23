pragma ComponentBehavior:Bound

import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import "../components"

Scope{
  WorkspaceOsdController{id:controller}

  Instantiator{
    model:Quickshell.screens

    delegate:PanelWindow{
      required property var modelData
      screen:modelData
      visible:toast.isOsdActive
      implicitWidth:toast.width
      implicitHeight:toast.height
      color:"transparent"
      anchors.bottom:true
      margins.bottom:9
      exclusionMode:ExclusionMode.Ignore
      focusable:false
      mask:Region{}
      WlrLayershell.layer:WlrLayer.Overlay
      WlrLayershell.namespace:"workspace-osd"

      WorkspaceToast{id:toast}

      Connections{
        target:controller
        function onShowRequested(monitor,workspace,caption,slot,persistent){
          if(monitor===modelData.name)toast.present(workspace,caption,slot,persistent)
        }
        function onHideRequested(monitor){
          if(!monitor||monitor===modelData.name)toast.hide()
        }
      }
    }
  }
}
