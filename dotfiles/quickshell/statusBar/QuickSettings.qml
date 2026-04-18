import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Io

ExpandableModule {
  id: quickSettings
  
  collapsedHeight: 45
  expandedHeight: 180
  clickeable: true

  // --- LÓGICA DE ACTUALIZACIÓN INTELIGENTE ---
  
  function refreshData() {
    if (!wifiFetcher.running) wifiFetcher.running = true;
    if (!brightnessFetcher.running) brightnessFetcher.running = true;
  }

  // Refrescar inmediatamente al expandir el widget
  onExpandedChanged: if (expanded) refreshData();

  // Timer de seguridad: solo refresca cada 30s si la barra no se usa.
  // Es mucho más eficiente que cada 5s.
  Timer {
    interval: 30000 
    running: true
    repeat: true
    onTriggered: refreshData()
  }

  // --- SERVICIOS Y DATOS ---
  
  property int brightness: 0
  property int maxBrightness: 1
  
  Process {
    id: brightnessFetcher
    command: ["brightnessctl", "g"]
    stdout: StdioCollector {
      onStreamFinished: {
        let val = parseInt(this.text.trim());
        if (!isNaN(val)) quickSettings.brightness = val;
        // Solo pedimos el máximo una vez para ahorrar
        if (quickSettings.maxBrightness === 1) brightnessMaxFetcher.running = true;
      }
    }
  }
  
  Process {
    id: brightnessMaxFetcher
    command: ["brightnessctl", "m"]
    stdout: StdioCollector {
      onStreamFinished: {
        let val = parseInt(this.text.trim());
        if (!isNaN(val)) quickSettings.maxBrightness = val;
      }
    }
  }

  Process { id: brightnessSetter }

  property string ssid: "Desconectado"
  
  Process {
    id: wifiFetcher
    // Usamos LC_ALL=C para que "yes" sea consistente independientemente del idioma del sistema
    command: ["sh", "-c", "LC_ALL=C nmcli -t -f active,ssid dev wifi"]
    stdout: StdioCollector {
      onStreamFinished: {
        let lines = this.text.split("\n");
        let found = false;
        for (let line of lines) {
          if (line.startsWith("yes:")) {
            quickSettings.ssid = line.split(":")[1];
            found = true;
            break;
          }
        }
        if (!found) quickSettings.ssid = "Desconectado";
      }
    }
  }

  // --- UI COLAPSADA ---

  collapsedContent: Component {
    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      spacing: 10

      // WiFi Icon
      Row {
        spacing: 4
        Text {
          text: quickSettings.ssid !== "Desconectado" ? "" : "󰖪"
          font.pixelSize: 14
          color: quickSettings.ssid !== "Desconectado" ? "#a6e3a1" : "#6c7086"
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // Vol Icon (Reactivo automáticamente por Pipewire)
      Row {
        spacing: 4
        property var node: Pipewire.defaultAudioSink
        Text {
          text: parent.node && !parent.node.muted ? (parent.node.audio.volume > 0.5 ? "" : "") : "󰝟"
          font.pixelSize: 14
          color: "#89b4fa"
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: parent.node ? Math.round(parent.node.audio.volume * 100) + "%" : "0%"
          color: "#cdd6f4"
          font.pixelSize: 11
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // Brightness Icon
      Row {
        spacing: 4
        Text {
          text: "󰃠"
          font.pixelSize: 14
          color: "#f9e2af"
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: Math.round((quickSettings.brightness / quickSettings.maxBrightness) * 100) + "%"
          color: "#cdd6f4"
          font.pixelSize: 11
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }
  }

  // --- UI EXPANDIDA ---

  expandedContent: Component {
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 15
      spacing: 12

      // Wi-Fi Status Card
      Rectangle {
        Layout.fillWidth: true
        height: 35
        color: "#181825"
        radius: 6
        border.color: "#313244"
        
        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          Text {
            text: ""
            color: "#a6e3a1"
            font.pixelSize: 14
          }
          Text {
            Layout.fillWidth: true
            text: quickSettings.ssid
            color: "#cdd6f4"
            font.pixelSize: 12
            elide: Text.ElideRight
            font.weight: Font.Medium
          }
        }
      }

      // Volume Slider
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        Text { text: "Volumen"; color: "#a6adc8"; font.pixelSize: 11 }
        
        Rectangle {
          id: volBar
          Layout.fillWidth: true
          height: 25
          color: "#181825"
          radius: 12
          clip: true

          property var node: Pipewire.defaultAudioSink

          Rectangle {
            width: parent.width * (parent.node ? parent.node.audio.volume : 0)
            height: parent.height
            color: "#89b4fa"
            radius: 12
          }

          MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => updateVol(mouse)
            onPositionChanged: (mouse) => updateVol(mouse)
            function updateVol(mouse) {
              if (volBar.node) {
                let val = Math.max(0, Math.min(1, mouse.x / width));
                volBar.node.audio.volume = val;
              }
            }
          }
        }
      }

      // Brightness Slider
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        Text { text: "Brillo"; color: "#a6adc8"; font.pixelSize: 11 }
        
        Rectangle {
          id: brightBar
          Layout.fillWidth: true
          height: 25
          color: "#181825"
          radius: 12
          clip: true

          Rectangle {
            width: parent.width * (quickSettings.brightness / quickSettings.maxBrightness)
            height: parent.height
            color: "#f9e2af"
            radius: 12
          }

          MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => updateBright(mouse)
            onPositionChanged: (mouse) => updateBright(mouse)
            function updateBright(mouse) {
              let pct = Math.max(0, Math.min(1, mouse.x / width));
              let val = Math.round(pct * quickSettings.maxBrightness);
              quickSettings.brightness = val;
              brightnessSetter.exec(["brightnessctl", "s", val.toString()]);
            }
          }
        }
      }
    }
  }

  // Al cargar el componente por primera vez
  Component.onCompleted: refreshData()
}
