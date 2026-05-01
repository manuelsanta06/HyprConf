import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
  id: root
  Layout.fillWidth: true
  implicitHeight: 45

  // --- LOGICA DE BRILLO ---
  property int brightness: 0
  property int maxBrightness: 1
  
  function updateInfo() {
    brightnessFetcher.running = true;
    if (maxBrightness === 1) brightnessMaxFetcher.running = true;
  }

  Process {
    id: brightnessFetcher
    command: ["brightnessctl", "g"]
    stdout: StdioCollector {
      onStreamFinished: {
        let val = parseInt(this.text.trim());
        if (!isNaN(val)) root.brightness = val;
      }
    }
  }
  
  Process {
    id: brightnessMaxFetcher
    command: ["brightnessctl", "m"]
    stdout: StdioCollector {
      onStreamFinished: {
        let val = parseInt(this.text.trim());
        if (!isNaN(val)) root.maxBrightness = val;
      }
    }
  }

  Process { id: brightnessSetter }
  
  Component.onCompleted: updateInfo()

  // --- DISEÑO TIPO ANDROID ---

  // Fondo (Igual al de ExpandableModule)
  Rectangle {
    anchors.fill: parent
    color: "#1affffff"
    radius: 6
    clip: true

    // Barra de Progreso (Color claro pero no blanco)
    Rectangle {
      id: progress
      width: parent.width * (root.brightness / root.maxBrightness)
      height: parent.height
      color: "#1793d1" // Gris marfil / Off-white
      radius: 6
      
      // Animación suave al cambiar el valor
      Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    // Contenido (Icono y Porcentaje)
    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      
      Text {
        text: "󰃠"
        font.pixelSize: 18
        // Si el progreso llega al icono, invertimos el color para que se vea
        color: (root.brightness / root.maxBrightness) > 0.15 ? "#0f0f14" : "#e8e8f0"
        Behavior on color { ColorAnimation { duration: 200 } }
      }

      Item { Layout.fillWidth: true }

      Text {
        text: Math.round((root.brightness / root.maxBrightness) * 100) + "%"
        font.pixelSize: 12
        font.bold: true
        color: (root.brightness / root.maxBrightness) > 0.85 ? "#0f0f14" : "#cdd6f4"
        Behavior on color { ColorAnimation { duration: 200 } }
      }
    }

    // Interacción de deslizar
    MouseArea {
      anchors.fill: parent
      preventStealing: true
      onPositionChanged: (mouse) => update(mouse)
      onPressed: (mouse) => update(mouse)
      
      function update(mouse) {
        let pct = Math.max(0, Math.min(1, mouse.x / width));
        let val = Math.round(pct * root.maxBrightness);
        root.brightness = val;
        brightnessSetter.exec(["brightnessctl", "s", val.toString()]);
      }
    }
  }

  // Refresco periódico (cada 30s) por si se cambia externamente
  Timer {
    interval: 30000
    running: true; repeat: true
    onTriggered: updateInfo()
  }
}
