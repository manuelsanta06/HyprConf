import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
  id: root
  Layout.fillWidth: true
  implicitHeight: 40

  // --- LÓGICA DE VOLUMEN (WPCTL) ---
  property real vol: 0
  property bool isMuted: false

  function updateInfo() {
    volFetcher.running = true;
  }

  Process {
    id: volFetcher
    command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
    stdout: StdioCollector {
      onStreamFinished: {
        // Formato esperado: "Volume: 0.50" o "Volume: 0.50 [MUTED]"
        let output = this.text.trim();
        let parts = output.split(" ");
        if (parts.length >= 2) {
          root.vol = parseFloat(parts[1]);
          root.isMuted = output.includes("[MUTED]");
        }
      }
    }
  }

  Process { id: volSetter }

  // Refrescar al cargar y periódicamente
  Component.onCompleted: updateInfo()
  
  // Timer para detectar cambios externos (teclas multimedia)
  Timer {
    interval: 2000
    running: true; repeat: true
    onTriggered: updateInfo()
  }

  // --- DISEÑO ---
  Rectangle {
    anchors.fill: parent
    radius: 8
    color: "#1affffff"
    clip: true

    // Barra de Progreso
    Rectangle {
      id: progress
      width: parent.width * Math.min(root.vol, 1.0)
      height: parent.height
      color: root.isMuted ? "#6c7086" : "#89b4fa"
      radius: 8
      
      Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 200 } }
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 12; anchors.rightMargin: 12
      
      Text {
        text: root.isMuted ? "󰝟" : (root.vol > 0.5 ? "" : "")
        color: root.vol > 0.15 ? "#0f0f14" : "#89b4fa"
        font.pixelSize: 14
      }

      Item { Layout.fillWidth: true }

      Text {
        text: Math.round(root.vol * 100) + "%"
        color: root.vol > 0.85 ? "#0f0f14" : "#cdd6f4"
        font.pixelSize: 11; font.bold: true
      }
    }

    MouseArea {
      anchors.fill: parent
      preventStealing: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onPositionChanged: (mouse) => { if (mouse.buttons & Qt.LeftButton) update(mouse) }
      onPressed: (mouse) => {
        if (mouse.button === Qt.RightButton) {
          volSetter.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", root.isMuted ? "0" : "1"]);
          root.isMuted = !root.isMuted;
        } else {
          update(mouse)
        }
      }
      
      function update(mouse) {
        let pct = Math.max(0, Math.min(1.5, mouse.x / width)); // Permite hasta 150% si el sistema lo soporta
        root.vol = pct;
        volSetter.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.min(pct, 1.0).toFixed(2)]);
        
        // Si estaba muteado, desmutear al mover
        if (root.isMuted) {
          volSetter.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"]);
          root.isMuted = false;
        }
      }
    }
  }
}
