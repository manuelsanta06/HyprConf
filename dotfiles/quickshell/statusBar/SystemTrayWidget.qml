pragma ComponentBehavior:Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray as Tray
import ".."

Item{
  id:root

  property bool active:true
  property var items:Tray.SystemTray.items.values
  property var menuItem:null
  readonly property bool menuOpen:menuAnchor.visible
  readonly property int columns:Math.max(1,Math.floor((width+6)/38))

  visible:items.length>0
  implicitHeight:icons.implicitHeight+8

  onItemsChanged:{
    if(menuItem&&!items.includes(menuItem)){
      if(menuAnchor.visible)menuAnchor.close()
      menuItem=null
    }
  }

  function openMenu(item,button){
    if(!item.hasMenu)return
    if(menuAnchor.visible)menuAnchor.close()
    menuItem=item
    menuAnchor.anchor.item=button
    menuAnchor.open()
  }

  QsMenuAnchor{
    id:menuAnchor
    menu:root.menuItem?root.menuItem.menu:null
    anchor.edges:Edges.Right|Edges.Top
    anchor.gravity:Edges.Right|Edges.Bottom
    onClosed:root.menuItem=null
  }

  Flow{
    id:icons
    anchors.horizontalCenter:parent.horizontalCenter
    y:4
    width:Math.max(0,Math.min(root.items.length,root.columns)*38-6)
    spacing:6

    Repeater{
      model:root.items

      Rectangle{
        id:button
        required property var modelData
        readonly property bool selected:root.menuOpen&&root.menuItem===modelData
        readonly property bool attention:modelData.status===Tray.Status.NeedsAttention

        width:32
        height:32
        radius:8
        color:attention?Qt.alpha(Theme.accent,0.16)
          :mouse.containsMouse||selected?Qt.alpha(Theme.foreground,0.09):"transparent"
        Behavior on color{ColorAnimation{duration:120}}

        Image{
          id:icon
          anchors.centerIn:parent
          width:20
          height:20
          source:button.modelData.icon
          sourceSize:Qt.size(width,height)
          fillMode:Image.PreserveAspectFit
          smooth:true
          opacity:mouse.containsMouse||button.modelData.status!==Tray.Status.Passive?1:0.7
          Behavior on opacity{NumberAnimation{duration:120}}
        }

        Text{
          anchors.centerIn:parent
          visible:icon.status!==Image.Ready
          text:"◇"
          color:Theme.foreground
          font.pixelSize:20
        }

        ToolTip.visible:root.active&&mouse.containsMouse&&!root.menuOpen
        ToolTip.delay:500
        ToolTip.timeout:3000
        ToolTip.text:modelData.tooltipTitle||modelData.title||modelData.id

        MouseArea{
          id:mouse
          anchors.fill:parent
          hoverEnabled:true
          cursorShape:Qt.PointingHandCursor
          acceptedButtons:Qt.LeftButton|Qt.RightButton|Qt.MiddleButton

          onClicked:mouse=>{
            const item=button.modelData
            if(mouse.button===Qt.RightButton||(mouse.button===Qt.LeftButton&&item.onlyMenu))
              root.openMenu(item,button)
            else if(mouse.button===Qt.MiddleButton)item.secondaryActivate()
            else item.activate()
          }
          onWheel:wheel=>{
            const horizontal=Math.abs(wheel.angleDelta.x)>Math.abs(wheel.angleDelta.y)
            button.modelData.scroll(horizontal?wheel.angleDelta.x:wheel.angleDelta.y,horizontal)
            wheel.accepted=true
          }
        }
      }
    }
  }
}
