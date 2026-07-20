import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: root
  //Tunables
  readonly property int hideDelayMs:500
  readonly property int revealMs:200
  readonly property int barWidth:220
  readonly property int triggerPx:4 
  readonly property int hideMs:300


  required property var modelData
  screen: modelData

  // Layer-shell config
  aboveWindows:true
  exclusionMode:ExclusionMode.Ignore
  WlrLayershell.namespace:"statusbar"
  HyprlandWindow.visibleMask:Region{item:barBody}

  anchors{left:true;top:true;bottom:true;}

  // width:barWidth
  implicitWidth:(root.revealed||xAnim.running)?root.barWidth:root.triggerPx
  color:"transparent"


  property bool revealed:false

  //Auto-hide timer
  Timer{
    id:hideTimer
    interval:root.hideDelayMs
    repeat:false
    onTriggered:root.revealed=false
  }

  HoverHandler{
    id:rootHover
    onHoveredChanged:{
      if(hovered){hideTimer.stop();root.revealed=true;}
      else{hideTimer.restart();}
    }
  }

  //Bar panel
  Rectangle{
    id:barBody
    color:"#c20f0f14"

    x:root.revealed?0:-root.barWidth
    y:0
    width:root.barWidth
    height:root.height
    clip:true


    Behavior on x{
      NumberAnimation{
        id: xAnim
        duration:root.revealed?root.revealMs:root.hideMs
        easing.type:Easing.InOutQuart
      }
    }
    Rectangle{
      anchors{right:parent.right;top:parent.top;bottom:parent.bottom}
      width:1
      color:"#44ffffff"
    }

    // ---CONTENT------------------------------------------------------------
    ColumnLayout{
      anchors{fill:parent;margins:12;}
      spacing:8

      // TOP
      Options{}

      Rectangle{Layout.fillWidth:true;implicitHeight:1;color:"#22ffffff"}
      WorkspaceWidget{}
      GithubStreak{textBottom:false}
      MediaPLayer{}

      // MIDDLE
      Item{Layout.fillHeight:true}
      Item{Layout.fillHeight:true}

      // BOTTOM
      Rectangle{Layout.fillWidth:true;implicitHeight:1;color:"#22ffffff" }
      NetworkWidget{}
      Battery{}
      Clock{textBottom:true}
    }
  }
}
