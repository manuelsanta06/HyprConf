import QtQuick
import QtQuick.Layouts

ExpandableModule {
  id: clockWidget
  
  property bool textBottom: false
  textOnBottom: textBottom
  clickeable: true
  collapsedHeight: 28 
  expandedHeight: 220

  // --- LÓGICA DEL CALENDARIO ---
  QtObject {
    id: calLogic
    property var today: new Date()
    property int month: today.getMonth()
    property int year: today.getFullYear()
    
    property var daysName: ["L", "M", "M", "J", "V", "S", "D"]
    
    function firstDayOffset() {
      let d = new Date(year, month, 1).getDay();
      return (d === 0) ? 6 : d - 1;
    }
    
    function daysInMonth() {
      return new Date(year, month + 1, 0).getDate();
    }
  }

  // --- UI COLAPSADA ---
  collapsedContent: Component {
    Item {
      Text {
        anchors.centerIn: parent
        text: Qt.formatTime(wallClock.now, "HH:mm")
        font.pixelSize: 18
        font.family: "monospace"
        color: "#e8e8f0"
        font.weight: Font.Bold
      }
    }
  }

  // --- UI EXPANDIDA: CALENDARIO COMPACTO ---
  expandedContent: Component {
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 8 // Menos margen para ganar espacio
      spacing: 8

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(calLogic.today, "MMMM yyyy").toUpperCase()
        color: "#1793d1"
        font.pixelSize: 11
        font.bold: true
        font.letterSpacing: 1
      }

      // Grilla ultra-compacta
      GridLayout {
        columns: 7
        rowSpacing: 4
        columnSpacing: 2 // Espaciado mínimo para que no se corte el domingo
        Layout.fillWidth: true

        Repeater {
          model: calLogic.daysName
          Text {
            text: modelData
            color: "#6c7086"
            font.pixelSize: 10
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
          }
        }

        Repeater {
          model: calLogic.firstDayOffset()
          Item { Layout.preferredWidth: 22; Layout.preferredHeight: 22 }
        }

        Repeater {
          model: calLogic.daysInMonth()
          Rectangle {
            Layout.preferredWidth: 22 // Celdas más pequeñas
            Layout.preferredHeight: 22
            radius: 11
            color: (index + 1 === calLogic.today.getDate()) ? "#1793d1" : "transparent"

            Text {
              anchors.centerIn: parent
              text: index + 1
              font.pixelSize: 9 // Fuente un punto más pequeña
              font.bold: (index + 1 === calLogic.today.getDate())
              color: (index + 1 === calLogic.today.getDate()) ? "#11111b" : "#cdd6f4"
            }
          }
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(calLogic.today, "dddd, d MMM")
        font.pixelSize: 9
        color: "#6c7086"
        font.italic: true
      }
    }
  }

  QtObject {
    id: wallClock
    property var now: new Date()
  }
  
  Timer {
    interval: 1000; repeat: true; running: true
    onTriggered: wallClock.now = new Date()
  }
}
