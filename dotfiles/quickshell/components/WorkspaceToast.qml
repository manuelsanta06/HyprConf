import QtQuick
import ".."

OsdBase{
  id:root

  property string workspace:""
  property string caption:"WORKSPACE"
  property int slot:-1
  readonly property real numberWidth:Math.max(50,Math.min(130,number.implicitWidth))

  position:"bottom"
  width:numberWidth+details.width+73
  height:92
  padding:8
  backgroundColor:"transparent"
  hideDelay:1100
  animationDuration:260
  opacity:state==="visible"?1:0
  Behavior on opacity{NumberAnimation{duration:160;easing.type:Easing.OutCubic}}

  function present(workspace,caption,slot,persistent){
    const changed=root.workspace!==workspace||root.caption!==caption
    root.workspace=workspace
    root.caption=caption
    root.slot=slot
    root.keepOpen=persistent
    show()
    if(changed)numberEnter.restart()
  }

  Rectangle{
    anchors.fill:parent
    anchors.topMargin:5
    anchors.bottomMargin:-5
    radius:22
    color:"#18000000"
  }

  Rectangle{
    id:card
    anchors.fill:parent
    radius:20
    color:Qt.alpha(Theme.background,0.97)
    border.width:1
    border.color:Qt.alpha(Theme.foreground,0.12)

    Item{
      id:numberZone
      anchors.left:parent.left
      anchors.leftMargin:16
      anchors.verticalCenter:parent.verticalCenter
      width:root.numberWidth
      height:48
      clip:true

      Text{
        id:number
        anchors.centerIn:parent
        width:Math.min(implicitWidth,130)
        text:root.workspace
        color:Theme.foreground
        font.pixelSize:/^\d+$/.test(root.workspace)?36:23
        font.weight:Font.DemiBold
        font.letterSpacing:-1
        elide:Text.ElideRight
        transform:Translate{id:numberShift}
      }
    }

    Rectangle{
      id:divider
      anchors.left:numberZone.right
      anchors.leftMargin:12
      anchors.verticalCenter:parent.verticalCenter
      width:1
      height:30
      color:Qt.alpha(Theme.foreground,0.1)
    }

    Column{
      id:details
      width:Math.max(captionLabel.implicitWidth,root.slot>=0?103:0,root.keepOpen?hint.implicitWidth:0)
      anchors.left:divider.right
      anchors.leftMargin:12
      anchors.verticalCenter:parent.verticalCenter
      spacing:root.keepOpen?7:10

      Text{
        id:captionLabel
        text:root.caption
        color:Qt.alpha(Theme.foreground,0.65)
        font.pixelSize:9
        font.weight:Font.DemiBold
        font.letterSpacing:0.8
      }

      Item{
        width:97
        height:3
        visible:root.slot>=0

        Row{
          spacing:3
          Repeater{
            model:10
            Rectangle{
              width:7
              height:3
              radius:1.5
              color:Qt.alpha(Theme.foreground,0.13)
            }
          }
        }

        Rectangle{
          x:root.slot*10
          width:7
          height:3
          radius:1.5
          color:Theme.accent
          Behavior on x{NumberAnimation{duration:150;easing.type:Easing.OutCubic}}
        }
      }

      Text{
        id:hint
        visible:root.keepOpen
        text:"0–9 select · Esc cancel"
        color:Qt.alpha(Theme.foreground,0.5)
        font.pixelSize:8
      }
    }
  }

  ParallelAnimation{
    id:numberEnter
    NumberAnimation{target:number;property:"opacity";from:0;to:1;duration:160}
    NumberAnimation{target:numberShift;property:"y";from:7;to:0;duration:220;easing.type:Easing.OutCubic}
  }
}
