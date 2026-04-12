pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Services.Mpris

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
  collapsedHeight:75
  expandedHeight:150
  property string savedArtUrl: ""
  property string dominantColor:"#181825"
  backgroundColor:mediaModule.dominantColor

  Process {
    id: colorExtractor
    command:["bash","-c",
      "magick '" + mediaModule.savedArtUrl.replace('file://', '') + "' -resize 1x1 txt:- | grep -o '#[0-9A-Fa-f]\\{6\\}' | head -n 1"
    ]

    stdout:StdioCollector{onStreamFinished:{
      let hexColor=this.text.trim();
      if(hexColor.startsWith("#")){
        mediaModule.dominantColor=hexColor;
      }
    }}

    stderr:StdioCollector{onStreamFinished:{
      console.log("Error extrayendo color: "+error)
      mediaModule.dominantColor = "#181825"
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
          
          //Play/Pausa (Dinámico)
          Text{
            // 1 significa reproduciendo en MPRIS
            text:(mediaModule.player&&mediaModule.player.playbackStatus===1)?"󰏤":"󰐊"
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
}
