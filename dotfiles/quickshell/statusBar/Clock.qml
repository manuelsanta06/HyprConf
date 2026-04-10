import QtQuick
import QtQuick.Layouts

ExpandableModule {
  property bool textBottom:false
  textOnBottom:textBottom
  collapsedHeight: 28
  expandedHeight:  170

  //Collapsed: digital HH:mm
  collapsedContent:Component{
    Item{
      Text{
        id:digitalText
        anchors.centerIn:parent
        text:Qt.formatTime(wallClock.now,"HH:mm")
        font.pixelSize:20
        font.family:"monospace"
        color:"#e8e8f0"
        font.weight:Font.Medium
      }
    }
  }

  //Expanded: analog clock
  expandedContent:Component{
    Item{
      Item{
        id:face
        anchors.centerIn:parent
        width:140
        height:140

        // Clock face circle
        Rectangle {
          anchors.fill: parent
          radius:       width/2
          color:        "transparent"
          border.color: "#44ffffff"
          border.width: 1
        }

        // Hour marks
        Repeater {
          model: 12
          Rectangle {
            property real angle: (index / 12.0) * Math.PI * 2
            property real r:     face.width / 2 - 8
            x: face.width / 2 + Math.sin(angle) * r - width  / 2
            y: face.height/ 2 - Math.cos(angle) * r - height / 2
            width:  index % 3 === 0 ? 6 : 3
            height: index % 3 === 0 ? 6 : 3
            radius: width / 2
            color:  index % 3 === 0 ? "#ccccdd" : "#557777aa"
          }
        }

        // Hour hand
        Rectangle {
          id: hourHand
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom:           parent.verticalCenter
          width:  4
          height: face.height * 0.25
          radius: 2
          color:  "#e0e0ee"
          transformOrigin: Item.Bottom
          rotation: {
            var d = wallClock.now
            return (d.getHours() % 12 + d.getMinutes() / 60.0) * 30
          }
        }

        // Minute hand
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom:           parent.verticalCenter
          width:  2
          height: face.height * 0.36
          radius: 1
          color:  "#a0c8ff"
          transformOrigin: Item.Bottom
          rotation: wallClock.now.getMinutes() * 6
        }

        // Second hand
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom:           parent.verticalCenter
          width:  1
          height: face.height * 0.40
          radius: 1
          color:  "#ff6655"
          transformOrigin: Item.Bottom
          rotation: wallClock.now.getSeconds() * 6
        }

        // Center dot
        Rectangle{
          anchors.centerIn:parent
          width:6;height:6
          radius:3
          color:"#ff6655"
        }
      }

      // Date below the clock face
      Text {
        anchors {
          horizontalCenter:parent.horizontalCenter
          bottom:textBottom?parent.parent:parent.bottom
          bottomMargin:8
        }
        text:Qt.formatDate(wallClock.now,"ddd d MMM")
        font.pixelSize:11
        color:"#778899"
      }
    }
  }

  //Shared wall-clock ticker
  QtObject {
    id: wallClock
    property var now: new Date()
  }
  Timer {
    interval: 1000; repeat: true; running: true
    onTriggered: wallClock.now = new Date()
  }
}
