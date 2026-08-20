pragma ComponentBehavior:Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../components"

ExpandableModule{
  id:root

  // The directory is the source of truth.
  // If a copy disappears, it disappears from the drawer too.
  readonly property string drawerDirectory:
    Quickshell.env("HOME")+"/.cache/statusbar/fileDrawer"

  property var files:[]
  property var pendingDropUrls:[]
  property string lastMessage:"Ready to use"
  property int queuedPrinterJobs:0

  // Copy queue
  property var copyQueue:[]
  property var activeCopy:null
  property int copyFailureCount:0
  readonly property bool copying:copyProcess.running||copyQueue.length>0

  // Print queue
  property bool printing:false
  property bool cancelRequested:false
  property var printQueue:[]
  property var activePrint:null
  property var submittedJobs:[]
  property int printIndex:0
  property int printTotal:0
  property int printFailureCount:0
  property string printOutput:""
  property string printError:""
  property bool submissionFinished:false
  property bool printTrackingAvailable:true
  property string printerOutput:""
  property bool printerStatusAvailable:false
  property bool refreshAfterCurrentPrinterQuery:false

  collapsedHeight:46
  expandedHeight:Math.min(300,Math.max(150,92+Math.min(root.files.length,6)*30))
  clickeable:true
  backgroundColor:"#1affffff"

  function pathToUrl(path){
    let segments=path.split("/");
    for(let i=0; i<segments.length; i++)
      segments[i]=encodeURIComponent(segments[i]);
    return "file://"+segments.join("/");
  }

  function pathFromUrl(url){
    if(!url)return "";

    if(typeof url.toLocalFile==="function"){
      let localPath=url.toLocalFile();
      if(localPath!=="")return localPath;
    }

    let rawUrl=typeof url.toString==="function"?url.toString():String(url);
    if(rawUrl.indexOf("file://")!==0)return"";
    return decodeURIComponent(rawUrl.substring(7));
  }

  function fileNameFromPath(path){
    return path.substring(path.lastIndexOf("/")+1);
  }

  function nameTaken(name,extraNames){
    for(let i=0;i<root.files.length;i++){
      if(root.files[i].name===name)return true;
    }

    for(let i=0;i<root.copyQueue.length;i++){
      if(root.copyQueue[i].name===name)return true;
    }

    for(let i=0;i<extraNames.length;i++){
      if(extraNames[i]===name)return true;
    }

    return false;
  }

  function uniqueName(originalName,extraNames){
    let dot=originalName.lastIndexOf(".");
    let hasExtension=dot>0;
    let stem=hasExtension?originalName.substring(0,dot):originalName;
    let extension=hasExtension?originalName.substring(dot):"";
    let candidate=originalName;
    let suffix=1;

    while(root.nameTaken(candidate,extraNames)){
      candidate=stem+"("+suffix+")"+extension;
      suffix++;
    }

    return candidate;
  }

  function refreshFiles(){
    if(!storageReady||fileScanner.running)return;
    fileScanner.exec([
      "find",root.drawerDirectory,
      "-mindepth","1","-maxdepth","1","-type","f",
      "-printf","%f\\n"
    ]);
  }

  function enqueueDroppedUrls(urls){
    if(root.printing||!urls||urls.length === 0)return;

    if(!storageReady){
      root.pendingDropUrls=root.pendingDropUrls.concat(urls);
      root.lastMessage="Preparing file drawer...";
      return;
    }

    let queue=root.copyQueue.slice();
    let names=[];

    for(let i=0;i<urls.length;i++){
      let sourcePath=root.pathFromUrl(urls[i]);
      if(sourcePath===""){
        root.lastMessage="Only local files can be copied";
        continue;
      }

      // Do not duplicate files by dropping one of the drawer's own copies
      // back onto the drawer.
      if(sourcePath === root.drawerDirectory||sourcePath.indexOf(root.drawerDirectory+"/")===0){
        continue;
      }

      let originalName=root.fileNameFromPath(sourcePath);
      if(originalName==="")continue;

      let destinationName=root.uniqueName(originalName,names);
      names.push(destinationName);
      queue.push({
        source:sourcePath,
        name:destinationName,
        destination:root.drawerDirectory+"/"+destinationName
      });
    }

    if(queue.length===root.copyQueue.length)return;

    if(!root.copying)root.copyFailureCount=0;
    root.copyQueue=queue;
    root.startNextCopy();
  }

  function startNextCopy(){
    if(copyProcess.running||root.copyQueue.length===0)return;

    root.activeCopy=root.copyQueue[0];
    copyProcess.exec([
      "cp","--",
      root.activeCopy.source,
      root.activeCopy.destination
    ]);
  }

  function deleteFile(file){
    if(root.printing||deleteProcess.running||!file)return;
    deleteProcess.exec(["rm","-f","--",file.path]);
  }

  function clearFiles(){
    if(root.printing||root.copying||root.files.length===0)return;

    let command=["rm","-f","--"];
    for(let i=0;i<root.files.length;i++)
      command.push(root.files[i].path);
    deleteProcess.exec(command);
  }

  function startPrinting(){
    if(root.printing||root.copying||root.files.length === 0)return;

    root.printQueue=root.files.slice();
    root.printTotal=root.printQueue.length;
    root.printIndex=0;
    root.printFailureCount=0;
    root.submittedJobs=[];
    root.cancelRequested=false;
    root.submissionFinished=false;
    root.printTrackingAvailable=true;
    root.printing=true;
    root.startNextPrint();
  }

  function startNextPrint(){
    if(!root.printing||root.cancelRequested)return;

    if(root.printIndex>=root.printQueue.length){
      root.submissionFinished=true;
      root.lastMessage=root.submittedJobs.length>0
        ?"Waiting for printer..."
       :"No jobs sent to printer";

      if(root.submittedJobs.length === 0||!root.printTrackingAvailable){
        root.finishPrinting(false);
      }else{
        root.refreshPrinterStatus();
      }
      return;
    }

    root.activePrint=root.printQueue[root.printIndex];
    root.lastMessage="Sending "+(root.printIndex+1)+
      "/"+root.printTotal+" to printer";
    printProcess.exec(["lp","--",root.activePrint.path]);
  }

  function extractJobId(output){
    let match=output.match(/request id is\s+(.+?)\s+\(/i);
    return match?match[1].trim():"";
  }

  function finishPrinting(wasCancelled){
    root.printing=false;
    root.activePrint=null;
    root.printQueue=[];

    if(wasCancelled){
      root.lastMessage="Print stopped";
    }else if(root.printFailureCount>0){
      root.lastMessage=root.printFailureCount+
        " file"+(root.printFailureCount===1?"":"s")+" couldnt be printed";
    } else{
      root.lastMessage=root.printTotal+" file"+
       (root.printTotal===1?"":"s")+" sent to printer";
    }

    root.cancelRequested=false;
    root.submissionFinished=false;
    root.refreshPrinterStatus();
  }

  function cancelPrinting(){
    if(!root.printing||root.cancelRequested)return;

    root.cancelRequested=true;
    root.lastMessage="Stopping impresion...";

    if(root.submittedJobs.length>0 && !cancelProcess.running)
      cancelProcess.exec(["cancel"].concat(root.submittedJobs));

    if(printProcess.running){
      printProcess.signal(15);
    }else{
      root.finishPrinting(true);
    }
  }

  function refreshPrinterStatus(){
    if(printerStatusProcess.running){
      if(root.submissionFinished)root.refreshAfterCurrentPrinterQuery=true;
      return;
    }
    printerStatusProcess.exec(["lpstat","-W","not-completed","-o"]);
  }

  function checkPrintCompletion(){
    if(!root.printing||!root.submissionFinished||
        !root.printTrackingAvailable||!root.printerStatusAvailable){
      return;
    }

    let lines=root.printerOutput===""
      ?[]:root.printerOutput.split(/\r?\n/);
    let activeJobs=0;

    for(let i=0; i<root.submittedJobs.length;i++){
      for(let j=0; j<lines.length; j++){
        let firstColumn=lines[j].trim().split(/\s+/)[0];
        if(firstColumn === root.submittedJobs[i]){
          activeJobs++;
          break;
        }
      }
    }

    if(activeJobs===0)root.finishPrinting(false);
  }

  Component.onCompleted:storageProcess.exec(["mkdir","-p",root.drawerDirectory])

  property bool storageReady:false

  Process{
    id:storageProcess

    onExited:function(exitCode){
      if(exitCode!==0){
        root.lastMessage="Error reading files";
        return;
      }

      root.storageReady=true;
      root.refreshFiles();
      root.refreshPrinterStatus();

      if(root.pendingDropUrls.length>0){
        let pendingUrls=root.pendingDropUrls.slice();
        root.pendingDropUrls=[];
        root.enqueueDroppedUrls(pendingUrls);
      }
    }
  }

  Process{
    id:fileScanner

    stdout:StdioCollector{
      onStreamFinished:{
        let names=this.text.trim()===""
          ?[]:this.text.trim().split(/\r?\n/);
        names.sort();

        let nextFiles=[];
        for(let i=0;i<names.length;i++){
          if(names[i]==="")continue;
          nextFiles.push({
            name:names[i],
            path:root.drawerDirectory+"/"+names[i]
          });
        }
        root.files=nextFiles;
      }
    }
  }

  Process{
    id:copyProcess

    stderr:StdioCollector{
      onStreamFinished:{
        root.lastMessage=this.text.trim();
      }
    }

    onExited:function(exitCode){
      let copiedFile=root.activeCopy;
      root.activeCopy=null;
      root.copyQueue=root.copyQueue.slice(1);

      if(exitCode!==0){
        root.copyFailureCount++;
      }

      if(root.copyQueue.length>0){
        root.startNextCopy();
        return;
      }

      if(root.copyFailureCount>0){
        root.lastMessage=root.copyFailureCount+" file" +(root.copyFailureCount===1?"":"s")+" couldnt be copied";
      }else if(copiedFile){
        root.lastMessage="File"+(root.copyFailureCount===1?"":"s")+" added";
      }

      root.refreshFiles();
    }
  }

  Process{
    id:deleteProcess

    stderr:StdioCollector{
      onStreamFinished:{
        let error=this.text.trim();
        if(error!=="")root.lastMessage=error;
      }
    }

    onExited:function(exitCode){
      if(exitCode===0)root.lastMessage="Archivo eliminado";
      root.refreshFiles();
    }
  }

  Process{
    id:printProcess
    environment:({ LC_ALL:"C" })

    stdout:StdioCollector{
      onStreamFinished:root.printOutput=this.text.trim()
    }

    stderr:StdioCollector{
      onStreamFinished:root.printError=this.text.trim()
    }

    onExited:function(exitCode){
      if(!root.activePrint)return;

      if(exitCode===0){
        let jobId=root.extractJobId(root.printOutput);
        if(jobId!==""){
          root.submittedJobs=root.submittedJobs.concat([jobId]);
        }else{
          root.printTrackingAvailable=false;
        }
      } else{
        root.printFailureCount++;
      }

      root.printIndex++;
      root.activePrint=null;

      if(root.cancelRequested){
        root.finishPrinting(true);
      }else{
        root.startNextPrint();
      }
    }
  }

  Process{id:cancelProcess}

  Process{
    id:printerStatusProcess
    environment:({ LC_ALL:"C" })

    stdout:StdioCollector{
      onStreamFinished:{
        root.printerStatusAvailable=true;
        root.printerOutput=this.text.trim();
        let lines=this.text.trim()===""
          ?[]
         :this.text.trim().split(/\r?\n/);
        root.queuedPrinterJobs=lines.length;
      }
    }

    stderr:StdioCollector{
      onStreamFinished:{
        if(this.text.trim()!==""){
          root.printerStatusAvailable=false;
          root.queuedPrinterJobs=-1;
        }
      }
    }

    onExited:function(exitCode){
      if(root.refreshAfterCurrentPrinterQuery){
        root.refreshAfterCurrentPrinterQuery=false;
        root.refreshPrinterStatus();
        return;
      }

      if(exitCode !== 0)root.printerStatusAvailable=false;
      root.checkPrintCompletion();
    }
  }

  Timer{
    interval:3000
    running:root.storageReady
    repeat:true
    onTriggered:root.refreshFiles()
  }

  Timer{
    interval:4000
    running:root.storageReady
    repeat:true
    onTriggered:root.refreshPrinterStatus()
  }

  collapsedContent:Component{
    Item{
      anchors.fill:parent

      RowLayout{
        anchors.fill:parent
        anchors.leftMargin:12
        anchors.rightMargin:12
        spacing:10

        Text{
          text:root.printing?"󰐊":"󰈙"
          color:root.printing?"#f9e2af":"#cdd6f4"
          font.pixelSize:20
        }

        ColumnLayout{
          Layout.fillWidth:true
          spacing:0

          Text{
            Layout.fillWidth:true
            text:root.printing?"Imprimiendo":"Bandeja"
            color:"#cdd6f4"
            font.pixelSize:12
            font.bold:true
            elide:Text.ElideRight
          }

          Text{
            Layout.fillWidth:true
            text:root.printing
              ?(root.printIndex + " / " + root.printTotal)
             :(root.files.length + " archivo" +
               (root.files.length === 1?"":"s"))
            color:root.printing?"#f9e2af":"#a6adc8"
            font.pixelSize:10
            elide:Text.ElideRight
          }
        }
      }
    }
  }

  expandedContent:Component{
    Item{
      anchors.fill:parent
      anchors.margins:8

      ColumnLayout{
        anchors.fill:parent
        spacing:6

        RowLayout{
          Layout.fillWidth:true

          Text{
            text:"BANDEJA DE ARCHIVOS"
            color:"#1793d1"
            font.pixelSize:10
            font.bold:true
            font.letterSpacing:1
          }

          Item{ Layout.fillWidth:true }

          Text{
            text:root.files.length
            color:"#6c7086"
            font.pixelSize:10
          }
        }

        Item{
          Layout.fillWidth:true
          Layout.fillHeight:true
          Layout.minimumHeight:0

          Text{
            anchors.centerIn:parent
            visible:root.files.length===0
            text:"Drop files here"
            color:"#6c7086"
            font.pixelSize:11
            font.italic:true
          }

          ListView{
            anchors.fill:parent
            visible:root.files.length>0
            model:root.files
            spacing:4
            clip:true

            delegate:Item{
              required property var modelData
              property var fileData:modelData

              width:ListView.view.width
              height:28

              Rectangle{
                anchors.fill:parent
                radius:5
                color:fileDragHandler.active?"#401793d1":"#181825"
                border.width:fileDragHandler.active?1:0
                border.color:"#1793d1"
              }

              Text{
                anchors.left:parent.left
                anchors.leftMargin:8
                anchors.right:deleteButton.left
                anchors.rightMargin:4
                anchors.verticalCenter:parent.verticalCenter
                text:"󰈙  "+fileData.name
                color:"#cdd6f4"
                font.pixelSize:10
                elide:Text.ElideRight
              }

              Drag.active:fileDragHandler.active&&!root.printing
              Drag.dragType:Drag.Automatic
              Drag.supportedActions:Qt.CopyAction
              Drag.proposedAction:Qt.CopyAction
              Drag.hotSpot.x:width/2
              Drag.hotSpot.y:height/2
              Drag.mimeData:({
                "text/uri-list":root.pathToUrl(fileData.path)+ "\r\n"
              })

              Text{
                id:deleteButton
                anchors.right:parent.right
                anchors.rightMargin:8
                anchors.verticalCenter:parent.verticalCenter
                text:"󰩺"
                color:deleteHover.hovered?"#f38ba8":"#6c7086"
                font.pixelSize:15

                HoverHandler{id:deleteHover}
                TapHandler{
                  enabled:!root.printing
                  onTapped:root.deleteFile(fileData)
                }
              }

              DragHandler{
                id:fileDragHandler
                enabled:!root.printing
                target:null
                acceptedButtons:Qt.LeftButton
              }
            }
          }
        }

        Text{
          Layout.fillWidth:true
          text:root.printing
            ?root.lastMessage
           :(root.lastMessage+
             (root.queuedPrinterJobs>=0
                ?" · Queue:"+root.queuedPrinterJobs
               :""))
          color:root.printing?"#f9e2af":"#6c7086"
          font.pixelSize:9
          elide:Text.ElideRight
        }

        RowLayout{
          Layout.fillWidth:true
          spacing:6

          Rectangle{
            Layout.fillWidth:true
            implicitHeight:30
            radius:6
            color:root.printing?"#6c7086":
             (root.files.length>0&&!root.copying?"#1793d1":"#313244")
            opacity:root.printing||root.files.length>0 && !root.copying?1:0.65

            Text{
              anchors.centerIn:parent
              text:root.printing?"󰜺  Stop":"  Print"
              color:root.printing||root.files.length>0?"#11111b":"#6c7086"
              font.pixelSize:10
              font.bold:true
            }

            TapHandler{
              enabled:root.printing ||(root.files.length>0 && !root.copying)
              onTapped:root.printing?root.cancelPrinting():root.startPrinting()
            }
          }

          Rectangle{
            Layout.preferredWidth:66
            implicitHeight:30
            radius:6
            color:root.printing||root.copying||root.files.length===0
              ?"#313244":"#1affffff"

            Text{
              anchors.centerIn:parent
              text:"Vaciar"
              color:root.printing||root.copying||root.files.length===0
                ?"#6c7086":"#cdd6f4"
              font.pixelSize:10
            }

            TapHandler{
              enabled:!root.printing&&!root.copying&&root.files.length>0
              onTapped:root.clearFiles()
            }
          }
        }
      }
    }
  }

  DropArea{
    id:drawerDropArea
    anchors.fill:parent
    enabled:!root.printing

    onEntered:root.expanded=true
    onDropped:function(drop){
      if(!root.printing&&drop.urls&&drop.urls.length>0){
        drop.accept(Qt.CopyAction);
        root.enqueueDroppedUrls(drop.urls);
      }
    }

    Rectangle{
      anchors.fill:parent
      visible:drawerDropArea.containsDrag&&!root.printing
      radius:6
      color:"#401793d1"
      border.width:1
      border.color:"#1793d1"

      Text{
        anchors.centerIn:parent
        text:"Drop to save"
        color:"#cdd6f4"
        font.pixelSize:11
        font.bold:true
      }
    }
  }
}
