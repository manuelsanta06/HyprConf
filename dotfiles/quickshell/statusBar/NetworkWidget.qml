import QtQuick
import QtQuick.Layouts
import Quickshell.Io
pragma ComponentBehavior:Bound
import "../components"

ExpandableModule{
  id:netWidget
  
  collapsedHeight:45
  expandedHeight:0 
  clickeable:true
  implicitHeight:collapsedHeight

  property string ssid:"Searching..."
  property string type:"wifi"
  property int strength:0
  property string accent:"#1793d1"

  function getIcon() {
    if(ssid==="Disconected")return "󰖪";
    if(type==="ethernet")return "󰈀";
    
    if(strength<25)return "󰤟";
    if(strength<50)return "󰤢";
    if(strength<75)return "󰤥";
    return "󰤨";
  }

  function refresh(){
    wifiFetcher.running=true;
  }

  // main fetcher: conection name
  Process{
    id:wifiFetcher
    command:["sh", "-c", "LC_ALL=C nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected:' | head -n 1"]
    stdout:StdioCollector{
      onStreamFinished:{
        let output=this.text.trim();
        if(output===""){
          netWidget.ssid="Desconectado";
          netWidget.type="wifi";
          netWidget.strength=0;
          return;
        }
        
        let parts=output.split(":");
        // parts[0] = TYPE, parts[1] = STATE, parts[2] = CONNECTION (SSID)
        netWidget.type=parts[0].toLowerCase();
        netWidget.ssid=parts[2]||"connected";
        
        if(netWidget.type==="wifi"){
          strengthFetcher.running=true;
        }else{
          netWidget.strength=100;
        }
      }
    }
  }

  // secondary fetcher: connection strenght
  Process{
    id:strengthFetcher
    command:["sh", "-c", "LC_ALL=C nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d':' -f2"]
    stdout:StdioCollector{
      onStreamFinished:{
        let val=parseInt(this.text.trim());
        if(!isNaN(val))netWidget.strength=val;
      }
    }
  }

  Process{id:cmdRunner}

  Component.onCompleted:refresh()
  Timer{interval:10000;running:true;repeat:true;onTriggered:refresh()}

  collapsedContent:Component{
    RowLayout{
      anchors.fill: parent
      anchors.leftMargin:16
      anchors.rightMargin:16
      spacing:12

      Text{
        text:netWidget.getIcon()
        font.pixelSize:18
        color:netWidget.ssid!=="Disconected"?netWidget.accent:"#f38ba8"
        //TODO: better network config
        TapHandler{
          id:tapHandler
          onTapped:{
            // cmdRunner.exec(["hyprctl", "dispatch", "exec", "[float; size 550 800; center] kitty nmtui"]);
            cmdRunner.exec(["kitty","nmtui"]);
          }
        }
      }

      Text{
        Layout.fillWidth:true
        text:netWidget.ssid
        color:"#cdd6f4"
        font.pixelSize:13
        font.bold:true
        elide:Text.ElideRight
      }
    }
  }

  expandedContent:Component{Item{}}
}
