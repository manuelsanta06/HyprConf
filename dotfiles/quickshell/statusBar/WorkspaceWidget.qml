import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../components"
import ".."

ExpandableModule{
  id:root

  property int workspaceCount:10
  property bool active:true
  readonly property int currentGroup:WorkspaceState.currentGroup
  readonly property var workspaceState:WorkspaceState
  property var currentWorkspace:workspaceState.currentWorkspace
  property var focusedWindow:Hyprland.activeToplevel

  collapsedHeight:48
  expandedHeight:130
  clickeable:true
  backgroundColor:"#1affffff"

  function workspaceFor(number){
    const workspaces=workspaceState.workspaces
    for(let i=0;i<workspaces.length;i++){
      if(workspaces[i].id===number)
        return workspaces[i]
    }
    return null
  }

  function switchTo(position){
    Hyprland.dispatch("function() workspaceGroups.changeWorkspace("+position+",false) end")
  }

  function switchGroup(number){
    Hyprland.dispatch("function() workspaceGroups.changeGroup("+number+",false) end")
  }

  function workspacesForGroup(number){
    const first=number*root.workspaceCount+1
    return workspaceState.workspaces.filter(workspace=>
      workspace.id>=first&&workspace.id<first+root.workspaceCount)
  }

  function workspaceLabel(workspace){
    if(!workspace)return "Vacío"
    if(workspace.hasfullscreen)return "Pantalla completa"
    return workspace.windows+" ventana"+
      (workspace.windows===1?"":"s")
  }

  collapsedContent:Component{
    RowLayout{
      anchors.fill:parent
      anchors.leftMargin:12
      anchors.rightMargin:12
      spacing:10

      Rectangle{
        Layout.preferredWidth:36
        Layout.preferredHeight:30
        radius:8
        color:Theme.accent

        Text{
          anchors.centerIn:parent
          text:root.currentWorkspace?(root.currentWorkspace.id??root.currentWorkspace.address):"–"
          color:"#11111b"
          font.pixelSize:16
          font.bold:true
        }
      }

      ColumnLayout{
        Layout.fillWidth:true
        spacing:1

        MarqueeText{
          Layout.fillWidth:true
          active:root.active
          text:root.focusedWindow?root.focusedWindow.title:"Sin ventana enfocada"
          color:"#cdd6f4"
          font.pixelSize:12
          font.bold:true
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
          text:"GRUPO "+root.currentGroup
          color:Theme.accent
          font.pixelSize:10
          font.bold:true
          font.letterSpacing:1
        }

        Item{Layout.fillWidth:true}

        Text{
          text:root.currentWorkspace&&root.currentWorkspace.monitor
            ?root.currentWorkspace.monitor:""
          color:"#6c7086"
          font.pixelSize:10
        }
      }

      RowLayout{
        Layout.fillWidth:true
        spacing:2

        Repeater{
          model:10

          Rectangle{
            required property int index
            readonly property bool active:index===root.currentGroup
            readonly property var workspaces:root.workspacesForGroup(index)
            readonly property bool occupied:workspaces.some(workspace=>workspace.windows>0)
            readonly property bool urgent:workspaces.some(workspace=>workspaceState.isUrgent(workspace))

            Layout.fillWidth:true
            Layout.preferredHeight:22
            radius:4
            color:active?Theme.accent:(occupied?"#7F111224":"#50181825")
            border.width:urgent?1:0
            border.color:"#f38ba8"

            Text{
              anchors.centerIn:parent
              text:parent.index
              color:parent.active?Theme.accentFor:(parent.occupied?"#cdd6f4":"#6c7086")
              font.pixelSize:11
              font.bold:parent.active
            }

            HoverHandler{cursorShape:Qt.PointingHandCursor}
            TapHandler{onTapped:root.switchGroup(parent.index)}
          }
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
            readonly property int workspaceNumber:root.currentGroup*root.workspaceCount+index+1
            readonly property var workspace:root.workspaceFor(workspaceNumber)
            readonly property bool active:workspace&&root.currentWorkspace&&workspace.address===root.currentWorkspace.address
            readonly property bool occupied:workspace&&workspace.windows>0

            Layout.fillWidth:true
            Layout.preferredHeight:28
            radius:6
            color:active?Theme.accent:(occupied?"#7F111224":"#50181825")
            border.width:workspace&&workspaceState.isUrgent(workspace)?1:0
            border.color:"#f38ba8"

            Text{
              anchors.centerIn:parent
              text:parent.workspaceNumber
              color:parent.active?Theme.accentFor:(parent.occupied?"#cdd6f4":"#6c7086")
              font.pixelSize:12
              font.bold:parent.active
            }

            HoverHandler{id:workspaceHover;cursorShape:Qt.PointingHandCursor}
            TapHandler{onTapped:root.switchTo(parent.index+1)}

            scale:workspaceHover.hovered?1.06:1
            Behavior on scale{NumberAnimation{duration:120}}
          }
        }
      }
    }
  }
}
