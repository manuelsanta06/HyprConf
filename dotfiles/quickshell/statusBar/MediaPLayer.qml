pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Services.Mpris
import "../components"

ExpandableModule{
  id:mediaModule
  property var player: getBestPlayer(Mpris.players.values)

  function getBestPlayer(players){
    if(players.length===0)return null;
    for(let i=0;i<players.length;i++){
      let name=players[i].identity.toLowerCase();
      if(name.includes("zen")||name.includes("ytmusic"))return players[i];
    }
    for (let i=0;i<players.length;i++)if(players[i].playbackStatus===1)return players[i];
    return players[0];
  }
  visible:player!==null

  clickeable:true
  hideColapsed:false
  textOnBottom:false
  collapsedHeight:75
  expandedHeight:75
  property string savedArtUrl:""
  property string dominantColor:"#181825"
  backgroundColor:mediaModule.dominantColor

  property int cavaBars:30
  property real cavaGain: 1.8
  property var audioLevels:Array(cavaBars).fill(0)

  Process{
    id:cavaProcess
    command:["cava","-p",Quickshell.shellPath("extras/cava.conf")]
    running:mediaModule.expanded

    stdout:SplitParser{
      onRead:(data)=>{
        let frames=data.toString().trim().split(/\r?\n/).filter(frame=>frame.length>0);
        if(frames.length===0)return;
        let values=frames[frames.length-1].split(";").filter(value=>value.length>0);
        let half=mediaModule.cavaBars/2;
        if(values.length<half)return;
        
        let halfLevels=[];
        for(let i=0;i<half;i++){
          let level=Number(values[i]);
          if(!isNaN(level))halfLevels.push(Math.max(0,Math.min(1,(level/100)*mediaModule.cavaGain)));
        }

        let newLevels=[];
        for(let i=half-1;i>=0;i--)newLevels.push(halfLevels[i]);
        for(let i=0;i<half;i++)newLevels.push(halfLevels[i]);

        mediaModule.audioLevels=newLevels;
      }
    }

    stderr:StdioCollector{
      onStreamFinished:{
        if(this.text)console.log("Error en Cava: "+this.text);
      }
    }
  }

  Process{
    id:colorExtractor
    command:["bash","-c",
      "magick -quiet '" + mediaModule.savedArtUrl.replace('file://', '') + "' -resize 1x1 txt:- | grep -o '#[0-9A-Fa-f]\\{6\\}' | head -n 1"
    ]

    stdout:StdioCollector{onStreamFinished:{
      let hexColor=this.text.trim();
      if(hexColor.startsWith("#")){
        mediaModule.dominantColor=hexColor;
      }else{
        mediaModule.dominantColor="#181825";
      }
    }}

    stderr:StdioCollector{onStreamFinished:{
      let err=this.text.trim();
      if(err)console.log("Advertencia en colorExtractor: "+err);
    }}
  }

  collapsedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:6

      //Imagen (Izquierda)
      Rectangle{
        id:art
        width:parent.height
        height:parent.height
        anchors.left:parent.left
        radius:4
        color:"#181825"
        clip:true


        Connections{
          target:mediaModule.player
          function onTrackArtUrlChanged(){
            if(mediaModule.player&&mediaModule.player.trackArtUrl!==""){
              mediaModule.savedArtUrl=mediaModule.player.trackArtUrl
            }
            if(mediaModule.savedArtUrl.startsWith("file://")){
              colorExtractor.running=true;
            }else{
              // Si es una URL web o no hay imagen, volvemos al color por defecto
              mediaModule.dominantColor="#181825";
            }
          }
        }

        onParentChanged:{
          if(!mediaModule.player){mediaModule.savedArtUrl="";}
        }

        Image{
          anchors.fill:parent
          source:mediaModule.savedArtUrl
          fillMode:Image.PreserveAspectCrop
        }
      }

      //Textos y Controles (Derecha)
      Item{
        anchors.left:art.right
        anchors.right:parent.right
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.leftMargin:8

        //Títulos (Arriba)
        Column{
          anchors.top:parent.top
          anchors.left:parent.left
          anchors.right:parent.right
          spacing:0
          Text{
            width:parent.width
            text:mediaModule.player?mediaModule.player.trackTitle:"Sin reproducir"
            color:"#cdd6f4"
            font.pixelSize:14
            font.bold:true
            elide:Text.ElideRight
          }
          Text{
            width:parent.width
            text:mediaModule.player?mediaModule.player.trackArtist:""
            color:"#a6adc8"
            font.pixelSize:11
            elide:Text.ElideRight
          }
        }

        //Controles (Abajo)
        Row{
          anchors.bottom:parent.bottom
          anchors.horizontalCenter:parent.horizontalCenter
          spacing:15
          
          //Anterior
          Text{
            text:"󰒮"
            font.pixelSize:22
            color:hPrev.hovered?"#89b4fa":"#cdd6f4"
            HoverHandler{id:hPrev}
            MouseArea{anchors.fill:parent;onClicked:(mouse)=>{if(mediaModule.player)mediaModule.player.previous();mouse.accepted=true}}
          }
          
          //Play/Pausa
          Text{
            text:(mediaModule.player&&mediaModule.player.playbackState==MprisPlaybackState.Playing)?"󰏤":"󰐊"
            font.pixelSize:22
            color:hPlay.hovered?"#89b4fa":"#cdd6f4"
            HoverHandler{id:hPlay}
            MouseArea{anchors.fill:parent;onClicked:(mouse)=>{if(mediaModule.player)mediaModule.player.togglePlaying();mouse.accepted=true}}
          }
          
          //Siguiente
          Text{
            text:"󰒭"
            font.pixelSize:22
            color:hNext.hovered?"#89b4fa":"#cdd6f4"
            HoverHandler{id:hNext}
            MouseArea{anchors.fill:parent;onClicked:(mouse)=>{if(mediaModule.player)mediaModule.player.next();mouse.accepted=true}}
          }
        }
      }
    }
  }

  expandedContent:Component{
    Item{
      anchors.fill:parent

      Row{
        id:visualizer
        anchors.top:parent.top
        anchors.horizontalCenter:parent.horizontalCenter
        width:parent.width
        height:parent.height
        property int minBarHeight:3
        property int barCount:Math.max(1,mediaModule.audioLevels.length)
        property real barGap:Math.min(4,Math.max(1,width/(barCount*6)))
        property real barWidth:Math.max(1,(width-(barGap*(barCount-1)))/barCount)
        spacing:barGap

        Repeater{
          model:mediaModule.audioLevels

          Rectangle{
            required property real modelData
            width:visualizer.barWidth
            height:Math.max(visualizer.minBarHeight,Math.min(visualizer.height,modelData*visualizer.height))
            y:0
            color:"#cdd6f4"
            radius:Math.min(2,width/2)
          }
        }
      }
    }
  }
}
