import QtQuick
import QtQuick.Layouts

ExpandableModule {
  id: optionsMenu
  
  collapsedHeight: 50
  expandedHeight: 110 // Altura para mostrar los dos componentes
  clickeable: true
  
  backgroundColor: "#11111b"

  // --- UI COLAPSADA: LOGO ---
  collapsedContent: Component {
    Item {
      anchors.fill: parent
      Text {
        anchors.centerIn: parent
        text: ""
        font.pixelSize: 30
        color: "#1793d1"
        scale: optionsMenu.expanded ? 0.8 : 1.0
        Behavior on scale { NumberAnimation { duration: 200 } }
      }
    }
  }

  // --- UI EXPANDIDA: COMPONENTES MODULARES ---
  expandedContent: Component {
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 8
      anchors.topMargin: 0
      spacing: 12

      // Simplemente llamamos a los archivos .qml externos
      VolumeWidget {}
      BrightnessWidget {}
    }
  }
}
