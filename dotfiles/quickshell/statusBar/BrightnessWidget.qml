import QtQuick
import Quickshell.Io

SliderWidget{
  id: root

  implicitHeight:45

  property int brightness:0
  property int maxBrightness:0

  level: root.maxBrightness>0?root.brightness/root.maxBrightness:0
  icon: "󰃠"
  progressColor: "#1793d1"
  iconColor: root.level>0.15?"#0f0f14":"#e8e8f0"
  valueColor: root.level>0.85?"#0f0f14":"#cdd6f4"
  leftMargin: 16
  rightMargin: 16
  cornerRadius: 6

  function updateInfo(){
    if(!root.active)return;

    brightnessFetcher.running=true;
    brightnessMaxFetcher.running=true;
  }

  function setBrightness(requestedLevel){
    if(root.maxBrightness<=0)return;

    const nextBrightness=Math.round(Math.max(0,Math.min(1,requestedLevel))*root.maxBrightness);

    root.brightness=nextBrightness;
    brightnessSetter.exec(["brightnessctl","s",nextBrightness.toString()]);
  }

  onLevelRequested:(requestedLevel)=>root.setBrightness(requestedLevel)

  Component.onCompleted:if(root.active)root.updateInfo()
  onActiveChanged:{
    if(root.active){
      root.updateInfo();
    }else{
      brightnessFetcher.running=false;
      brightnessMaxFetcher.running=false;
    }
  }

  Process{
    id:brightnessFetcher
    command:["brightnessctl","g"]

    stdout:StdioCollector{
      onStreamFinished:{
        const value=parseInt(this.text.trim());
        if(!isNaN(value))root.brightness=value;
      }
    }
  }

  Process{
    id: brightnessMaxFetcher
    command:["brightnessctl","m"]

    stdout:StdioCollector{
      onStreamFinished:{
        const value=parseInt(this.text.trim());
        if(!isNaN(value)&&value>0)root.maxBrightness=value;
      }
    }
  }

  Process{id:brightnessSetter}
}
