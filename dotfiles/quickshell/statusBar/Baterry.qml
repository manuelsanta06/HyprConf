import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Io

ExpandableModule{
  property bool textBottom:true
  textOnBottom:textBottom
  clickeable:true
  hideColapsed:false
  collapsedHeight:35
  expandedHeight:55

  expandedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:2

      property string activeProfile:"balanced"

      Process {
        id:profileFetcher
        command:["powerprofilesctl","get"]
        running:true 

        stdout:StdioCollector{onStreamFinished:{
            if(this.text){activeProfile=this.text.trim()}
        }}
      }

      Process{id:cmdRunner}

      ColumnLayout{
        anchors.fill:parent
        spacing:10

        //big pill
        Rectangle{
          anchors.centerIn: parent
          Layout.fillWidth:true
          height:42
          radius:height/2
          color:"#181825"
          border.color:"#313244"
          border.width:2

          Rectangle{
            id:indicator
            width:parent.width/3
            height:parent.height
            radius:parent.radius
            
            x:activeProfile==="power-saver"?0:
              activeProfile==="balanced"?parent.width/3:
              activeProfile==="performance"?(parent.width/3)*2:
              (parent.width/3)*2
            color:activeProfile==="power-saver"?"#a6e3a1":
              activeProfile==="balanced"?"#89b4fa":
              activeProfile==="performance"?"#8806ce":
              "#8806ce"
            opacity:0.2 

            Behavior on x{
              NumberAnimation{
                duration:350 
                easing.type:Easing.OutBack
              }
            }
            Behavior on color{ColorAnimation{duration:300}}
          }

          //power buttons
          Row{
            anchors.fill:parent

            //power-saver
            Item{
              width:parent.width/3
              height:parent.height
              Text{
                anchors.centerIn:parent
                text:""
                font.pixelSize:16
                color:activeProfile==="power-saver"?"#a6e3a1":"#6c7086"
                Behavior on color{ColorAnimation{duration:200}}
              }
              TapHandler{onTapped:{
                activeProfile="power-saver"
                cmdRunner.exec(["powerprofilesctl","set","power-saver"])
              }}
            }
            
            //balanced
            Item{
              width:parent.width/3
              height:parent.height
              Text{
                anchors.centerIn:parent
                text:""
                font.pixelSize:18
                color:activeProfile==="balanced"?"#89b4fa":"#6c7086"
                Behavior on color{ColorAnimation{duration:200}}
              }
              TapHandler{onTapped:{
                activeProfile="balanced"
                cmdRunner.exec(["powerprofilesctl","set","balanced"])
              }}
            }

            //performance
            Item{
              width:parent.width / 3
              height:parent.height
              Text{
                anchors.centerIn:parent
                text:""
                font.pixelSize:16
                color:activeProfile==="performance"?"#8806ce":"#6c7086"
                Behavior on color{ColorAnimation{duration:200 }}
              }
              TapHandler{onTapped:{
                activeProfile="performance"
                cmdRunner.exec(["powerprofilesctl","set","performance"])
              }}
            }
          }
        }
        
        Row{
           Layout.fillWidth:true
           Item{width:parent.width/3;Text{anchors.centerIn:parent;text:"Ahorro";color:"#a6adc8";font.pixelSize:11;font.weight:Font.Medium}}
           Item{width:parent.width/3;Text{anchors.centerIn:parent;text:"Normal";color:"#a6adc8";font.pixelSize:11;font.weight:Font.Medium}}
           Item{width:parent.width/3;Text{anchors.centerIn:parent;text:"Máximo";color:"#a6adc8";font.pixelSize:11;font.weight:Font.Medium}}
        }
      }
    }
  }

  collapsedContent:Component{
    Item{
      anchors.fill:parent 

      Process{id:cmdRunner}

      //battery
      Row{
        anchors.left:parent.left
        anchors.verticalCenter:parent.verticalCenter
        anchors.leftMargin:12
        spacing:8

        // Battery icon
        Item{
          width:26
          height:12
          anchors.verticalCenter:parent.verticalCenter

          // Border
          Rectangle{
            id:batteryBody
            width:22
            height:12
            color:"transparent"
            border.color:"#a6adc8"
            border.width:2
            radius:3
            anchors.left:parent.left
            anchors.verticalCenter:parent.verticalCenter

            // Battery level
            Rectangle{
              anchors.left:parent.left
              anchors.top:parent.top
              anchors.bottom:parent.bottom
              anchors.margins:2
              width:(parent.width - (anchors.margins * 2)) * (UPower.displayDevice.percentage)
              color:UPower.displayDevice.state==1?"#00ffff":
                UPower.displayDevice.state==4?"#8806ce":
                UPower.displayDevice.percentage<0.2?"#ff0000":
                "#00ff00"
              radius:1
            }
          }

          // Battery niple
          Rectangle{
            width:3
            height:6
            color:"#a6adc8"
            radius:1
            anchors.left:batteryBody.right
            anchors.verticalCenter:parent.verticalCenter
          }
        }

        // Texto del porcentaje
        Text{
          text:Math.round(UPower.displayDevice.percentage * 100) + "%"
          color:"#cdd6f4"
          font.pixelSize:13
          font.bold:true
          anchors.verticalCenter:parent.verticalCenter
        }
      }

      //power actions
      Row{
        anchors.right:parent.right
        anchors.verticalCenter:parent.verticalCenter
        anchors.rightMargin:5
        spacing:2

        Repeater{
          model:ListModel{
            ListElement{name:"Hibernar";icon:"";accent:"#cba6f7";command:"systemctl hibernate"}
            ListElement{name:"Reiniciar";icon:"";accent:"#89b4fa";command:"systemctl reboot"}
            ListElement{name:"Apagar";icon:"";accent:"#f38ba8";command:"systemctl poweroff"}
          }

          Rectangle{
            id:powerBtn
            width:30
            height:30
            radius:4
            color:"transparent"
            border.color:hover.hovered?model.accent:"transparent"
            border.width:1

            property bool actionTriggered:false

            HoverHandler{id:hover}
            
            TapHandler{
              id:tap
              onPressedChanged:{
                if(!pressed)powerBtn.actionTriggered=false
              }
            }

            Rectangle{
              anchors.left:parent.left
              anchors.top:parent.top
              anchors.bottom:parent.bottom
              radius:3
              color:model.accent
              opacity:0.3

              width:tap.pressed?parent.width:0

              Behavior on width{
                NumberAnimation{
                  duration:1000
                }
              }

              onWidthChanged:{
                if(width>=parent.width-0.5&&tap.pressed&&!powerBtn.actionTriggered){
                  powerBtn.actionTriggered=true;
                  console.log("Ejecutando acción:"+model.name)
                  
                  cmdRunner.exec(["sh", "-c", model.command])
                }
              }
            }

            // Ícono
            Text{
              anchors.centerIn:parent
              text:model.icon
              color:hover.hovered||tap.pressed?model.accent:"#cdd6f4"
              font.pixelSize:16
            }
          }
        }
      }
    }
  }
}
