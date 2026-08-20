import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

PanelWindow{
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
  HyprlandWindow.visibleMask:Region{
    Region{item:barBody}
    Region{item:triggerZone}
  }

  anchors{left:true;top:true;bottom:true;}

  // width:barWidth
  implicitWidth:(root.revealed||xAnim.running)?root.barWidth:root.triggerPx
  color:"transparent"


  property bool revealed:false

  // Keep a small input strip alive while the bar is hidden.
  Item{
    id:triggerZone
    width:root.triggerPx
    height:root.height
  }

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
      FileDrawer{id:fileDrawer}

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

  //File drop target
  DropArea{
    id:barDropArea
    anchors{left:parent.left;top:parent.top;bottom:parent.bottom}
    width:root.triggerPx
    enabled:!fileDrawer.printing

    onEntered:root.revealed=true
    onDropped:function(drop){
      if(!fileDrawer.printing&&drop.urls&&drop.urls.length>0){
        drop.accept(Qt.CopyAction);
        fileDrawer.expanded=true;
        fileDrawer.enqueueDroppedUrls(drop.urls);
      }
    }

    Rectangle{
      anchors.fill:parent
      visible:barDropArea.containsDrag&&!fileDrawer.printing
      color:"#401793d1"
      border.width:1
      border.color:"#1793d1"
    }
  }
}
