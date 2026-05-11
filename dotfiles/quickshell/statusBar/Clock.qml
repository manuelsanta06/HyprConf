import QtQuick
import QtQuick.Layouts

ExpandableModule{
  id:clockWidget
  
  property bool textBottom:false
  textOnBottom:textBottom
  clickeable:true
  collapsedHeight:28 
  expandedHeight:220

  QtObject{
    id:time
    property var now:new Date()
    property string timeStr:Qt.formatTime(now,"HH:mm")
    
    property int day:now.getDate()
    property int month:now.getMonth()
    property int year:now.getFullYear()
    property var daysName:["L","M","M","J","V","S","D"]
    
    property int firstDayOffset:{
      let d=new Date(year,month,1).getDay();
      return(d===0)?6:d-1;
    }
    property int daysInMonth:new Date(year, month + 1, 0).getDate()
  }

  Timer{
    running:true
    repeat:true
    interval:(60-new Date().getSeconds())*1000
    onTriggered:{
      time.now=new Date();
      interval=(60-time.now.getSeconds())*1000;
    }
  }

  collapsedContent:Component{
    Item{
      Text{
        anchors.centerIn:parent
        text:time.timeStr
        font.pixelSize:18
        font.family:"monospace"
        color:"#e8e8f0"
        font.weight:Font.Bold
      }
    }
  }

  expandedContent:Component{
    ColumnLayout{
      anchors.fill:parent
      anchors.margins:8
      spacing:8

      Text{
        Layout.alignment:Qt.AlignHCenter
        text:Qt.formatDate(time.now,"MMMM yyyy").toUpperCase()
        color:"#1793d1"
        font.pixelSize:11
        font.bold:true
        font.letterSpacing:1
      }

      GridLayout{
        columns:7
        rowSpacing:4
        columnSpacing:2
        Layout.fillWidth:true

        Repeater{
          model:time.daysName
          Text{
            text:modelData
            color:"#6c7086"
            font.pixelSize:10
            font.bold:true
            Layout.fillWidth:true
            horizontalAlignment:Text.AlignHCenter
          }
        }

        Repeater{
          model:time.firstDayOffset
          Item{ Layout.preferredWidth:22; Layout.preferredHeight:22 }
        }

        Repeater{
          model:time.daysInMonth
          Rectangle{
            Layout.preferredWidth:22
            Layout.preferredHeight:22
            radius:11
            // Reacciona al cambio de día automáticamente
            color:(index + 1 === time.day) ? "#1793d1" :"transparent"

            Text{
              anchors.centerIn:parent
              text:index + 1
              font.pixelSize:9
              font.bold:(index + 1 === time.day)
              color:(index + 1 === time.day) ? "#11111b" :"#cdd6f4"
            }
          }
        }
      }

      Text{
        Layout.alignment:Qt.AlignHCenter
        text:Qt.formatDate(time.now, "dddd, d MMM")
        font.pixelSize:9
        color:"#6c7086"
        font.italic:true
      }
    }
  }
}
