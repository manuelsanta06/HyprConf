import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Io
import "../components"
pragma ComponentBehavior:Bound

ExpandableModule{
  id:batteryWidget

  property color pillColor:"#66181825"

  property bool effectsEnabled:true
  property bool textBottom:true
  property string activeProfile:"balanced"
  textOnBottom:textBottom
  clickeable:true
  hideColapsed:false
  collapsedHeight:35
  expandedHeight:55

  expandedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:2

      Process {
        id:initFetcher
        command:["sh","-c","powerprofilesctl get;hyprctl getoption decoration:blur:enabled -j | jq '.bool'"]
        running:true

        stdout:StdioCollector{
          onStreamFinished:{
            if(!this.text)return
            let outputLines=this.text.trim().split('\n')
            
            if(outputLines.length<2)return
            batteryWidget.activeProfile=outputLines[0].trim()
            batteryWidget.effectsEnabled=(outputLines[1].trim()==="true")
            if(batteryWidget.activeProfile=="power-saver")batteryWidget.expandedHeight=90
          }
        }
      }

      Process{
        id:effectRunner
        command:["toggleDetails.sh"]
        running:false
        stdout:StdioCollector{
          onStreamFinished:{
            if(this.text)batteryWidget.effectsEnabled=(this.text.trim()==="true")
          }
        }
      }

      Process{id:cmdRunner}

      ColumnLayout{
        anchors.fill:parent
        Layout.alignment:Qt.AlignVCenter
        spacing:0

        //big pill
        Rectangle{
          Layout.fillWidth:true
          implicitHeight:42
          radius:height/2
          color:batteryWidget.pillColor
          border.color:"#313244"
          border.width:2

          Rectangle{
            id:indicator
            width:parent.width/3
            height:parent.height
            radius:parent.radius
            
            x:batteryWidget.activeProfile==="power-saver"?0:
              batteryWidget.activeProfile==="balanced"?parent.width/3:
              batteryWidget.activeProfile==="performance"?(parent.width/3)*2:
              (parent.width/3)*2
            color:batteryWidget.activeProfile==="power-saver"?"#a6e3a1":
              batteryWidget.activeProfile==="balanced"?"#89b4fa":
              batteryWidget.activeProfile==="performance"?"#8806ce":
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
                color:batteryWidget.activeProfile==="power-saver"?"#a6e3a1":"#6c7086"
                Behavior on color{ColorAnimation{duration:200}}
              }
              TapHandler{onTapped:{
                batteryWidget.activeProfile="power-saver"
                batteryWidget.expandedHeight=90
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
                color:batteryWidget.activeProfile==="balanced"?"#89b4fa":"#6c7086"
                Behavior on color{ColorAnimation{duration:200}}
              }
              TapHandler{onTapped:{
                batteryWidget.activeProfile="balanced"
                batteryWidget.expandedHeight=55
                if(!batteryWidget.effectsEnabled)
                  effectRunner.running=true
                cmdRunner.exec(["powerprofilesctl","set","balanced"])
              }}
            }
            //performance
            Item{
              width:parent.width/3
              height:parent.height
              Text{
                anchors.centerIn:parent
                text:""
                font.pixelSize:16
                color:batteryWidget.activeProfile==="performance"?"#8806ce":"#6c7086"
                Behavior on color{ColorAnimation{duration:200 }}
              }
              TapHandler{onTapped:{
                batteryWidget.activeProfile="performance"
                batteryWidget.expandedHeight=55
                if(!batteryWidget.effectsEnabled)
                  effectRunner.running=true
                cmdRunner.exec(["powerprofilesctl","set","performance"])
              }}
            }
          }
        }
        Rectangle{
          visible:batteryWidget.activeProfile==="power-saver"
          Layout.fillWidth:true
          implicitHeight:42
          radius:height/2
          color:batteryWidget.pillColor
          border.color:"#313244"
          border.width:2

          RowLayout{
            anchors.fill:parent
            anchors.margins:12
            spacing:10

            Text{
              Layout.fillWidth:true
              text:"Prettiness"
              color:"#cdd6f4"
              font.pixelSize:13
              font.weight:Font.Medium
            }

            Rectangle{
              id:toggleSwitch
              implicitWidth:36
              implicitHeight:20
              radius:10
              color:batteryWidget.effectsEnabled?"#a6e3a1":"#45475a"
              Behavior on color{ColorAnimation{duration:200}}

              Rectangle{
                width:16
                height:16
                radius:8
                color:"#1e1e2e"
                y:2
                x:batteryWidget.effectsEnabled?18:2
                Behavior on x{NumberAnimation{duration:200;easing.type:Easing.OutCubic}}
              }

              TapHandler{
                onTapped:{
                  effectRunner.running=true
                }
              }
            }
          }
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
          text:Math.round(UPower.displayDevice.percentage*100)+"%"
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

            required property string name
            required property string icon
            required property string accent
            required property string command

            width:30
            height:30
            radius:4
            color:"transparent"
            border.color:hover.hovered?accent:"transparent"
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
              color:powerBtn.accent
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
                  console.log("Ejecutando acción:"+powerBtn.name)
                  
                  cmdRunner.exec(["sh","-c",powerBtn.command])
                }
              }
            }

            // Ícono
            Text{
              anchors.centerIn:parent
              text:powerBtn.icon
              color:hover.hovered||tap.pressed?powerBtn.accent:"#cdd6f4"
              font.pixelSize:16
            }
          }
        }
      }
    }
  }
}
