import QtQuick
import Quickshell
import Quickshell.Services.Notifications as Notifs

PanelWindow{
  id:root
  anchors{
    top:true
    right:true
  }
  margins{
    top:16
    right:16
  }
  width:340
  height:1080
  color:"transparent"

  FontLoader{
    id:mcFont
    source:"file:///home/TU_USUARIO/.local/share/fonts/Monocraft-nerd-fonts-patched.ttc"
  }

  Notifs.NotificationServer{
    id:server
    onNotification:(notif)=>{
      notifModel.insert(0,{"n":notif})
    }
  }

  ListModel{
    id:notifModel
  }

  ListView{
    id:listView
    anchors.fill:parent
    model:notifModel
    spacing:8
    interactive:false
    clip:true

    add:Transition{
      NumberAnimation{
        property:"y"
        from:-100
        duration:400
        easing.type:Easing.OutQuad
      }
      NumberAnimation{
        property:"opacity"
        from:0
        to:1
        duration:300
      }
    }

    remove:Transition{
      NumberAnimation{
        property:"opacity"
        to:0
        duration:300
      }
      NumberAnimation{
        property:"scale"
        to:0.8
        duration:300
      }
    }

    delegate:Item{
      id:delegateItem
      width:340
      height:76

      Rectangle{
        anchors.fill:parent
        color:"#212121"
        border.color:"#000000"
        border.width:4

        Rectangle{
          anchors.fill:parent
          anchors.margins:4
          color:"transparent"
          border.color:"#555555"
          border.width:2
        }

        Row{
          anchors.fill:parent
          anchors.margins:12
          spacing:12

          Image{
            width:48
            height:48
            source:model.n.appIcon.startsWith("/")?"file://"+model.n.appIcon:model.n.appIcon
            fillMode:Image.PreserveAspectFit
            anchors.verticalCenter:parent.verticalCenter
          }

          Column{
            width:parent.width-60
            spacing:4
            anchors.verticalCenter:parent.verticalCenter

            Text{
              text:model.n.summary
              color:"#FFFF55"
              font.family:mcFont.name
              font.pixelSize:14
              elide:Text.ElideRight
              width:parent.width
            }

            Text{
              text:model.n.body
              color:"#FFFFFF"
              font.family:mcFont.name
              font.pixelSize:12
              elide:Text.ElideRight
              wrapMode:Text.WordWrap
              width:parent.width
              maximumLineCount:2
            }
          }
        }
      }

      Timer{
        running:true
        interval:5000
        onTriggered:notifModel.remove(index)
      }
    }
  }
}
