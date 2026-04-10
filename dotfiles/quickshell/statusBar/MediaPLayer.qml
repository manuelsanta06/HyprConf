import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

ExpandableModule {
    id: mediaModule
    clickeable: true
    textOnBottom: false

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    visible: player !== null

    // --- Vista Colapsada (Texto y botón de pausa) ---
    collapsedContent: Component {
        Item {
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Mostramos el artista y el título
                Text {
                    text: mediaModule.player ? (mediaModule.player.trackArtist + " - " + mediaModule.player.trackTitle) : ""
                    color: "#e8e8f0"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                // Botón Play/Pause rápido
                Rectangle {
                    width: 24; height: 24; radius: 12
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "⏯" 
                        color: "#1793d1"
                    }
                    TapHandler {
                        // Usamos las funciones nativas para pausar/reproducir
                        onTapped: if (mediaModule.player) mediaModule.player.togglePlaying()
                    }
                }
            }
        }
    }

    // --- Vista Expandida (Carátula y controles completos) ---
    expandedContent: Component {
        Item {
            // Aquí podríamos agregar una Image{} usando mediaModule.player.trackArtUrl
            // Y botones adicionales para mediaModule.player.next() y mediaModule.player.previous()
        }
    }
}
