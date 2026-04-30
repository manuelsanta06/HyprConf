import QtQuick
import QtQuick.Window
import Quickshell

PanelWindow{
    id: volumeOsdWindow
    
    visible:osd.isOsdActive
    
    implicitWidth:osd.width
    implicitHeight:osd.height
    color:"transparent"
    
    anchors{
        right:true
        top:true
    }
    margins{
        top:(Screen.height/4)-osd.height/2
    }
    
    OsdModule{
        id:osd
        position:"right"
        percentage:90
    }
}
