import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io

PanelWindow{
  id:brightnessOsdWindow
  visible:osd.isOsdActive
  implicitWidth:osd.width
  implicitHeight:osd.height
  color:"transparent"
  anchors{right:true;top:true}
  margins{top:Screen.height/4-osd.height/2}
  property real brightness:0
  property real maxBrightness:1
  Component.onCompleted:{
    maxFetcher.running=true
    initFetcher.running=true
  }
  Process{
    id:maxFetcher
    command:["sh","-c","cat /sys/class/backlight/*/max_brightness | head -n 1"]
    stdout:StdioCollector{
      onStreamFinished:{
        let val=parseFloat(this.text.trim())
        if(!isNaN(val))brightnessOsdWindow.maxBrightness=val
      }
    }
  }
  Process{
    id:initFetcher
    command:["sh","-c","cat /sys/class/backlight/*/brightness | head -n 1"]
    stdout:StdioCollector{
      onStreamFinished:{
        let val=parseFloat(this.text.trim())
        if(!isNaN(val))brightnessOsdWindow.brightness=val
        monitor.running=true
      }
    }
  }
  Process{
    id:monitor
    command:["sh","-c","stdbuf -oL udevadm monitor -s backlight | grep -m 1 'backlight' > /dev/null; cat /sys/class/backlight/*/brightness | head -n 1"]
    stdout:StdioCollector{
      onStreamFinished:{
        let val=parseFloat(this.text.trim())
        if(!isNaN(val)){
          brightnessOsdWindow.brightness=val
          osd.triggerShow()
        }
        monitor.running=true
      }
    }
  }
  OsdModule{
    id:osd
    position:"right"
    percentage:Math.round((brightnessOsdWindow.brightness/brightnessOsdWindow.maxBrightness)*100)
    icon:"󰃠"
    accentColor:"#f9e2af"
  }
}
