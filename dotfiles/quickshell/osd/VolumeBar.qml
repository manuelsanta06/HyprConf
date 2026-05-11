import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
  id: volumeOsdWindow
  property var audioNode: Pipewire.defaultAudioSink

  PwObjectTracker{objects:audioNode?[audioNode]:[]}
  property var audioData:audioNode?audioNode.audio:null

  property real vol:audioData?audioData.volume:0.0
  property bool isMuted:audioData?audioData.muted:false

  visible: osd.isOsdActive
  implicitWidth: osd.width
  implicitHeight: osd.height
  color: "transparent"

  anchors{right:true;top:true}
  margins{top:Screen.height/4*3-osd.height/2}

  Connections{
    target:audioData
    function onVolumeChanged(){osd.triggerShow()}
    function onMutedChanged(){osd.triggerShow()}
  }

  OsdBar{
    id:osd
    position:"right"
    percentage:Math.round((isNaN(volumeOsdWindow.vol)?0:volumeOsdWindow.vol)*100)
    icon:volumeOsdWindow.isMuted?"󰝟":volumeOsdWindow.vol>0.5?"":""
    accentColor:volumeOsdWindow.isMuted?"#6c7086":(isNaN(volumeOsdWindow.vol)?0:volumeOsdWindow.vol)>1?"#ff0000":"#a6e3a1"
  }
}
