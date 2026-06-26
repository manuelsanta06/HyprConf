pragma ComponentBehavior:Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io


ExpandableModule{
  id:root

  property bool textBottom:true
  textOnBottom:textBottom
  clickeable:true
  hideColapsed:false
  collapsedHeight:40
  expandedHeight:200

  property var last7Days:[0,0,0,0,0,0,0]
  property int currentStreak:0

  function getCommitColor(commits){
    if(commits===0)return "#161b22"
    if(commits<=2)return "#0e4429"
    if(commits<=4)return "#006d32"
    if(commits<=6)return "#26a641"
    return "#39d353"
  }
  function getStreakColor(streak){
    if(streak===0)return "#757575"
    if(streak< 10)return "#FFCA28"
    if(streak< 25)return "#FF9800"
    if(streak< 50)return "#F44336"
    if(streak< 75)return "#E91E63"
    if(streak<100)return "#9C27B0"
    return "#FFD700"
  }
  function getStreakIcon(streak){
    if(streak===0)return '󰒲'
    if(streak< 10)return ''
    if(streak< 25)return "󰈸"
    if(streak< 50)return ""
    if(streak< 75)return "󰖨"
    if(streak<100)return "" //TODO: get a better galaxy icon
    return ""
  }

  Process{
    id:githubProcess
    command:["bash","fetchGithub.sh"]
    running:true
    
    stdout:StdioCollector{
      onStreamFinished:{
        if(this.text.trim().length>0)root.updateGithubStats(this.text.trim());
      }
    }
  }

  expandedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:15

      // Conten
      Item{
        id:circleBox
        anchors.centerIn:parent
        width:Math.min(parent.width,parent.height)
        height:width

        //circle
        Rectangle{
          anchors.fill:parent
          radius:width/2
          color:"transparent"
          border.color:root.getStreakColor(root.currentStreak)
          border.width:6

          ColumnLayout{
            anchors.centerIn:parent
            spacing:-2

            Text{
              text:root.currentStreak
              color:"#cdd6f4"
              font.pixelSize:circleBox.width*0.35
              font.bold:true
              Layout.alignment:Qt.AlignHCenter
            }
            Text{
              text:"Streak"
              color:"#a6adc8"
              font.pixelSize:circleBox.width*0.12
              Layout.alignment:Qt.AlignHCenter
            }
          }
        }

        //mask
        Rectangle{
          width:circleBox.width*0.28
          height:width*1
          color:"#27272c"
          radius:height/2
          anchors.horizontalCenter:parent.horizontalCenter
          anchors.verticalCenter:parent.top
        }

        //fire
        Text{
          text:root.getStreakIcon(root.currentStreak)
          color:root.getStreakColor(root.currentStreak)
          font.pixelSize:circleBox.width*0.2
          anchors.horizontalCenter:parent.horizontalCenter
          anchors.verticalCenter:parent.top
        }
      }
    }
  }

  collapsedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:6

      Row{
        anchors.fill:parent
        spacing:8

        //GitHub responsive icon for fetching information
        Text{
          id:ghIcon
          text:""
          color:tapHandler.pressed ? "#39d353":"#cdd6f4"
          font.pixelSize:parent.height*0.8
          anchors.verticalCenter:parent.verticalCenter
          TapHandler{
            id:tapHandler
            onTapped:{githubProcess.running=true}
          }
          
          scale:tapHandler.pressed ? 0.9 : 1.0
          Behavior on scale{NumberAnimation{duration:100}}
          Behavior on color{ColorAnimation{duration:100}}
        }

        Item{
          id:gridBox
          width:parent.width-ghIcon.width-parent.spacing
          height:parent.height
          anchors.verticalCenter:parent.verticalCenter

          Row{
            id:squaresRow
            anchors.centerIn:parent
            spacing:4
            property real sqSize:Math.min((gridBox.width-(6*spacing))/7,gridBox.height)
            Repeater{
              model:root.last7Days.length
              Rectangle{
                required property int index
                width:squaresRow.sqSize
                height:squaresRow.sqSize
                radius:width*0.15 
                color:root.getCommitColor(root.last7Days[index])
                border.color:"#313244"
                border.width:root.last7Days[index]===0?1:0
              }
            }
          }
        }
      }
    }
  }

  function updateGithubStats(rawData){
    try{
      let json=JSON.parse(rawData);
      let weeks=json.data.user.contributionsCollection.contributionCalendar.weeks;

      let days=[];
      for(let i=0;i<weeks.length;i++){
        let wDays=weeks[i].contributionDays;
        for(let j=0;j<wDays.length;j++)days.push(wDays[j].contributionCount);
      }

      //last 7 days
      let last7=[];
      for(let i=Math.max(0,days.length-7);i<days.length;i++)last7.push(days[i]);
      root.last7Days=last7;

      //streak
      let streak=0;
      let p=days.length-1;
      if(days[p]===0)p--;

      for(;p>=0;p--){
        if(days[p]>0)streak++;
        else break;
      }
      root.currentStreak=streak;

    }catch(e){
      console.log("Error parsing GitHub JSON:",e);
    }
  }
}


