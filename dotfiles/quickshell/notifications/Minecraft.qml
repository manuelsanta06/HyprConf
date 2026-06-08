import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PanelWindow{
  id:root
  property int toastWidth:360
  property int toastHeight:84
  property int gap:1
  property int topMargin:5
  property int rightMargin:5
  property int maxVisible:5
  property var notifications:[]

  function addNotification(notification){
    const kept=notifications.filter((item)=>item.id!==notification.id)
    kept.slice(maxVisible-1).forEach((item)=>item.dismiss())
    notifications.filter((item)=>item.id===notification.id).forEach((item)=>item.dismiss())
    notification.tracked=true
    notification.closed.connect(()=>notifications=notifications.filter((item)=>item!==notification))
    notifications=[notification].concat(kept).slice(0,maxVisible)
  }

  function removeNotification(notification,expired){
    notifications=notifications.filter((item)=>item!==notification)
    if(expired)
      notification.expire()
    else
      notification.dismiss()
  }

  function iconSource(notification){
    const icon=notification.image||notification.appIcon
    if(!icon)
      return ""
    if(icon.startsWith("/"))
      return "file://"+icon
    if(icon.startsWith("file://")||icon.startsWith("image://"))
      return icon
    return Quickshell.iconPath(icon,true)
  }

  function urgencyColor(notification){
    if(notification.urgency===NotificationUrgency.Low)
      return "#aaaaaa"
    if(notification.urgency===NotificationUrgency.Critical)
      return "#aa00aa"
    return "#ffff55"
  }

  anchors{
    top:true
    right:true
  }
  margins{
    top:topMargin
    right:rightMargin
  }
  implicitWidth:toastWidth
  implicitHeight:(toastHeight+gap)*notifications.length
  color:"transparent"
  exclusionMode:ExclusionMode.Ignore

  FontLoader{
    id:mcFont
    source:"file://"+Quickshell.env("HOME")+"/.local/share/fonts/Monocraft-nerd-fonts-patched.ttc"
  }

  NotificationServer{
    id:server
    imageSupported:true
    bodySupported:true
    keepOnReload:false
    onNotification:(notification)=>root.addNotification(notification)
  }

  Column{
    anchors.fill:parent
    spacing:root.gap

    Repeater{
      model:root.notifications

      delegate:Item{
        id:toast
        required property var modelData
        width:root.toastWidth
        height:root.toastHeight
        opacity:0

        transform:Translate{
          id:slide
          y:-root.toastHeight-root.topMargin
        }

        Component.onCompleted:enter.start()

        ParallelAnimation{
          id:enter
          NumberAnimation{
            target:slide
            property:"y"
            to:0
            duration:420
            easing.type:Easing.OutBack
          }
          NumberAnimation{
            target:toast
            property:"opacity"
            to:1
            duration:160
          }
        }

        Timer{
          interval:toast.modelData.expireTimeout>0?toast.modelData.expireTimeout*1000:5000
          running:true
          onTriggered:root.removeNotification(toast.modelData,true)
        }

        Rectangle{
          anchors.fill:parent
          color:"#100f0b"
          border.color:"#000000"
          border.width:4

          Rectangle{
            anchors.fill:parent
            anchors.margins:4
            color:"transparent"
            border.color:"#5a5a5a"
            border.width:2
          }

          Rectangle{
            anchors.fill:parent
            anchors.margins:8
            color:"#2b2b2b"
            opacity:0.82
          }

          Row{
            anchors.fill:parent
            anchors.margins:14
            spacing:12

            Rectangle{
              width:50
              height:50
              anchors.verticalCenter:parent.verticalCenter
              color:"#3a3a3a"
              border.color:"#111111"
              border.width:3

              IconImage{
                anchors.centerIn:parent
                width:34
                height:34
                source:root.iconSource(toast.modelData)
                visible:source!==""
              }

              Text{
                anchors.centerIn:parent
                text:"?"
                visible:root.iconSource(toast.modelData)===""
                color:"#ffaa00"
                font.family:mcFont.name
                font.pixelSize:24
              }
            }

            Column{
              width:parent.width-62
              anchors.verticalCenter:parent.verticalCenter
              spacing:3

              Text{
                width:parent.width
                text:toast.modelData.summary||toast.modelData.appName||"Notification"
                color:root.urgencyColor(toast.modelData)
                font.family:mcFont.name
                font.pixelSize:15
                elide:Text.ElideRight
                textFormat:Text.PlainText
              }

              Text{
                width:parent.width
                text:toast.modelData.body||"Achievement get!"
                color:"#ffffff"
                font.family:mcFont.name
                font.pixelSize:12
                lineHeight:0.9
                wrapMode:Text.WordWrap
                maximumLineCount:2
                elide:Text.ElideRight
                textFormat:Text.PlainText
              }
            }
          }
        }

        MouseArea{
          anchors.fill:parent
          onClicked:root.removeNotification(toast.modelData,false)
        }
      }
    }
  }
}
