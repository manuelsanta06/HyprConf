import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../components"

ExpandableModule{
  id:root

  property int workspaceCount:10
  property var currentWorkspace:Hyprland.focusedWorkspace
  property var focusedWindow:Hyprland.activeToplevel

  collapsedHeight:48
  expandedHeight:108
  clickeable:true
  backgroundColor:"#1affffff"

  function workspaceFor(number){
    const workspaces=Hyprland.workspaces.values
    for(let i=0;i<workspaces.length;i++){
      if(workspaces[i].id===number)
        return workspaces[i]
    }
    return null
  }

  function switchTo(number){
    Hyprland.dispatch("hl.dsp.focus({workspace="+number+"})")
  }

  function workspaceLabel(workspace){
    if(!workspace)return "Vacío"
    if(workspace.hasFullscreen)return "Pantalla completa"
    return workspace.toplevels.values.length+" ventana"+
      (workspace.toplevels.values.length===1?"":"s")
  }

  collapsedContent:Component{
    RowLayout{
      anchors.fill:parent
      anchors.leftMargin:12
      anchors.rightMargin:12
      spacing:10

      Rectangle{
        Layout.preferredWidth:30
        Layout.preferredHeight:30
        radius:8
        color:"#1793d1"

        Text{
          anchors.centerIn:parent
          text:root.currentWorkspace?root.currentWorkspace.id:"–"
          color:"#11111b"
          font.pixelSize:16
          font.bold:true
        }
      }

      ColumnLayout{
        Layout.fillWidth:true
        spacing:1

        Text{
          Layout.fillWidth:true
          text:root.focusedWindow?root.focusedWindow.title:"Sin ventana enfocada"
          color:"#cdd6f4"
          font.pixelSize:12
          font.bold:true
          elide:Text.ElideRight
        }

        Text{
          Layout.fillWidth:true
          text:root.focusedWindow&&root.focusedWindow.lastIpcObject["class"]
            ?root.focusedWindow.lastIpcObject["class"]:root.workspaceLabel(root.currentWorkspace)
          color:"#a6adc8"
          font.pixelSize:10
          elide:Text.ElideRight
        }
      }

      Text{
        text:root.expanded?"󰅀":"󰅂"
        color:"#6c7086"
        font.pixelSize:14
      }
    }
  }

  expandedContent:Component{
    ColumnLayout{
      anchors.fill:parent
      anchors.margins:8
      spacing:5

      RowLayout{
        Layout.fillWidth:true

        Text{
          text:"ESPACIOS DE TRABAJO"
          color:"#1793d1"
          font.pixelSize:10
          font.bold:true
          font.letterSpacing:1
        }

        Item{Layout.fillWidth:true}

        Text{
          text:root.currentWorkspace&&root.currentWorkspace.monitor
            ?root.currentWorkspace.monitor.name:""
          color:"#6c7086"
          font.pixelSize:10
        }
      }

      GridLayout{
        Layout.fillWidth:true
        columns:5
        rowSpacing:4
        columnSpacing:4

        Repeater{
          model:root.workspaceCount

          Rectangle{
            required property int index
            readonly property int workspaceNumber:index+1
            readonly property var workspace:root.workspaceFor(workspaceNumber)
            readonly property bool active:workspace&&workspace.focused
            readonly property bool occupied:workspace&&workspace.toplevels.values.length>0

            Layout.fillWidth:true
            Layout.preferredHeight:28
            radius:6
            color:active?"#1793d1":(occupied?"#7F111224":"#50181825")
            border.width:workspace&&workspace.urgent?1:0
            border.color:"#f38ba8"

            Text{
              anchors.centerIn:parent
              text:parent.workspaceNumber
              color:parent.active?"#11111b":(parent.occupied?"#cdd6f4":"#6c7086")
              font.pixelSize:12
              font.bold:parent.active
            }

            HoverHandler{id:workspaceHover}
            TapHandler{onTapped:root.switchTo(parent.workspaceNumber)}

            scale:workspaceHover.hovered?1.06:1
            Behavior on scale{NumberAnimation{duration:120}}
          }
        }
      }
    }
  }
}
