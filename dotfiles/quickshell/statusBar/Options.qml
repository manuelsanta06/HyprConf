import QtQuick
import QtQuick.Layouts
import "../components"

ExpandableModule{
  id:optionsMenu
  
  collapsedHeight:50
  expandedHeight:110
  clickeable:true
  
  backgroundColor:"#0011111b"

  collapsedContent:Component{
    Item{
      anchors.fill:parent
      Text{
        anchors.centerIn:parent
        text:""
        font.pixelSize:30
        color:"#1793d1"
        scale:optionsMenu.expanded?0.8:1.0
        Behavior on scale{NumberAnimation{duration:200}}
      }
    }
  }

  expandedContent:Component{
    ColumnLayout{
      anchors.fill:parent
      anchors.margins:8
      anchors.topMargin:0
      spacing:12

      VolumeWidget{}
      BrightnessWidget{}
    }
  }
}
