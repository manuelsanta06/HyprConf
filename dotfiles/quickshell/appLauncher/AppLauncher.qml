import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

ShellRoot{
  GlobalShortcut{
    name:"launcher"
    description:"Toggle app launcher"
    onPressed:{
      launcher.toggle()
      if(launcher.state==="visible")Qt.callLater(function(){searchInput.forceActiveFocus()})
    }
  }

  HyprlandFocusGrab{
    active:launcher.state==="visible"
    windows:[launcherWindow]
    onCleared:{
      if(launcher.state==="visible"){
        launcher.hide()
        resetLauncher()
      }
    }
  }

  Process{
    id:appSearcher
    command:["bombini",""]
    running:false

    stdout:StdioCollector{
      onStreamFinished:{
        let rawOutput=text.trim()
        if(rawOutput.length>0){
          try{
            let results=JSON.parse(rawOutput)
            resultsList.model=results
            resultsList.currentIndex=0
          }catch(e){
            console.log("Error parseando JSON:",e)
          }
        }else resultsList.model=[]
      }
    }
  }

  Process{
    id:appRunner
    running:false
  }

  Timer{
    id:debounceTimer
    interval:150
    repeat:false
    onTriggered:{
      let query=searchInput.text.trim()
      if(query.length>0){
        appSearcher.command=["bombini",query]
        appSearcher.running=true
      }else{
        resultsList.model=[]
      }
    }
  }

  function resetLauncher(){
    searchInput.clear()
    resultsList.model=[]
  }

  function launchSelectedApp(execCommand){
    if(!execCommand)return
    appRunner.running=false
    appRunner.command=["sh","-c","setsid "+execCommand+" </dev/null >/dev/null 2>&1 &"]
    appRunner.running=true
    launcher.hide()
    resetLauncher()
  }

  PanelWindow{
    id:launcherWindow
    visible:launcher.isOsdActive
    implicitWidth:Screen.width
    implicitHeight:Screen.height
    color:"transparent"
    focusable:true
    aboveWindows:true
    exclusionMode:ExclusionMode.Ignore

    onVisibleChanged:{
      if(visible)Qt.callLater(function(){searchInput.forceActiveFocus()})
    }
    MouseArea{
      anchors.fill:parent
      onClicked:{
        launcher.hide()
        resetLauncher()
      }
    }

    OsdBase{
      id:launcher
      position:"top"
      keepOpen:true
      backgroundColor:"#1b1b29"
      width:520
      height:85+Math.min(resultsList.count*55,500)

      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter

      Behavior on height {
        NumberAnimation {
          duration:300
          easing.type:Easing.OutQuad
        }
      }

      ColumnLayout{
        anchors.fill:parent
        spacing:5

        TextField{
          id:searchInput
          Layout.fillWidth:true
          Layout.preferredHeight:60
          leftPadding:18
          rightPadding:18

          color:"white"
          selectionColor:"#89b4fa"
          selectedTextColor:"#1e1e2e"
          font.pixelSize:24
          verticalAlignment:TextInput.AlignVCenter
          
          placeholderText:"Search..."
          placeholderTextColor:"#6c7086"
          
          background:Rectangle{
            color:"transparent"
            Rectangle{
              width:parent.width
              height:1
              color:"#9597aa"
              anchors.bottom:parent.bottom
              visible:resultsList.count>0||true
            }
          }

          clip:true
          focus:true

          onTextEdited:{
            debounceTimer.restart()
          }
          Keys.onEscapePressed:{
            launcher.hide()
            resetLauncher()
          }
          Keys.onDownPressed:{
            if(resultsList.count>0){
              resultsList.forceActiveFocus()
            }
          }
          Keys.onReturnPressed:{
            if(resultsList.count>0){
              launchSelectedApp(resultsList.model[0].exec)
            }else{
              let customCommand=searchInput.text.trim()
              if(customCommand.length>0){
                launchSelectedApp(customCommand +" &")
              }
            }
          }
        }

        ListView{
          id:resultsList
          Layout.fillWidth:true
          Layout.fillHeight:true
          spacing:5
          clip:true
          model:[]
          
          highlightMoveDuration:150
          highlight:Rectangle{color:"#1793D1";radius:8}

          Keys.onUpPressed:{
            if(resultsList.currentIndex<=0){
              searchInput.forceActiveFocus()
            }else{
              resultsList.decrementCurrentIndex()
            }
          }
          Keys.onReturnPressed:{
            launchSelectedApp(resultsList.model[resultsList.currentIndex].exec)
          }
          Keys.onEscapePressed:{
            launcher.hide()
            resetLauncher()
          }

          delegate:ItemDelegate{
            width:resultsList.width
            height:50
            
            background:Rectangle{
              color:"#32343e7f"
              radius:8
            }
            
            required property var modelData
            property string appName:modelData.name
            property string appExec:modelData.exec
            property string appIcon:modelData.icon

            RowLayout{
              anchors.fill:parent
              anchors.leftMargin:18
              anchors.rightMargin:18
              spacing:15

              IconImage{
                implicitSize:28
                source:Quickshell.iconPath(appIcon,"archlinux-logo")
                color:"transparent"
                Layout.alignment:Qt.AlignVCenter
              }

              Text{
                text:appName
                color:"white"
                font.pixelSize:18
                Layout.fillWidth:true
                Layout.alignment:Qt.AlignVCenter
              }
            }

            onClicked:launchSelectedApp(appExec)
          }
        }
      }
    }
  }
}
