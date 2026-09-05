import QtQuick
import Quickshell.Io

SliderWidget{
  id: root

  property real vol:0
  property bool isMuted:false

  level:Math.max(0,Math.min(1,root.vol))
  icon:root.isMuted?"󰝟":(root.vol>0.5?"":"")
  progressColor:root.isMuted?"#6c7086":"#89b4fa"
  iconColor: root.level > 0.15?"#0f0f14":"#89b4fa"
  valueText: Math.round(root.vol*100)+"%"
  valueColor: root.level>0.85?"#0f0f14":"#cdd6f4"
  secondaryActionEnabled:true

  function updateInfo(){
    if(!root.active)return;
    volFetcher.running=true;
  }

  function setVolume(requestedLevel){
    const nextVolume=Math.max(0,Math.min(1,requestedLevel));
    root.vol=nextVolume;

    if(root.isMuted){
      root.isMuted=false;
      muteSetter.exec(["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","0"]);
    }

    volumeSetter.exec(["wpctl","set-volume","@DEFAULT_AUDIO_SINK@",nextVolume.toFixed(2),]);
  }

  function toggleMute(){
    const nextMuted=!root.isMuted;
    root.isMuted=nextMuted;
    muteSetter.exec(["wpctl","set-mute","@DEFAULT_AUDIO_SINK@",nextMuted?"1":"0"]);
  }

  onLevelRequested:(requestedLevel)=>root.setVolume(requestedLevel)
  onSecondaryActionRequested:root.toggleMute()

  Component.onCompleted:if(root.active)root.updateInfo()
  onActiveChanged:{
    if(root.active){
      root.updateInfo();
    }else{
      volFetcher.running=false;
    }
  }

  Process{
    id:volFetcher
    command:["wpctl","get-volume","@DEFAULT_AUDIO_SINK@"]

    stdout: StdioCollector{
      onStreamFinished:{
        const output=this.text.trim();
        const value=parseFloat(output.split(/\s+/)[1]);

        if(!isNaN(value)){
          root.vol=Math.max(0,Math.min(1,value));
          root.isMuted=output.includes("[MUTED]");
        }
      }
    }
  }

  Process{id:volumeSetter}
  Process{id:muteSetter}
}
