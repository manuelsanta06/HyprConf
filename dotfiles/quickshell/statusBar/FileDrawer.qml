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

  property var    files:[]
  property var    pendingDropUrls:[]
  property string lastMessage:"Ready to use"
  property int    queuedPrinterJobs:0

  // Copy queue
  property var copyQueue:[]
  property var activeCopy:null
  property int copyFailureCount:0
  readonly property bool copying:copyProcess.running||copyQueue.length>0

  // Print queue
  property bool   printing:false
  property bool   cancelRequested:false
  property var    printQueue:[]
  property var    activePrint:null
  property var    submittedJobs:[]
  property int    printIndex:0
  property int    printTotal:0
  property int    printFailureCount:0
  property string printOutput:""
  property string printError:""
  property bool   submissionFinished:false
  property bool   printTrackingAvailable:true
  property string printerOutput:""
  property bool   printerStatusAvailable:false
  property bool   refreshAfterCurrentPrinterQuery:false

  // Temporary LAN share (python http.server + qrencode)
  property bool   sharing:false
  property string shareHost:""
  property int    sharePort:0
  readonly property int shareListenPort:8765
  property string shareUrl:""
  property string qrPath:""
  property bool   qrReady:false
  property string shareStatusMessage:"Preparing link..."
  readonly property int shareTimeoutSeconds:600
  property int    shareSecondsLeft:0

  textOnBottom:true
  collapsedHeight:46
  expandedHeight:{
    let base=Math.min(300,Math.max(150,92+Math.min(root.files.length,6)*30));
    let shareSize=Math.min(260,Math.max(0,root.width-16));
    return root.sharing?base+shareSize+12:base;
  }
  clickeable:true
  backgroundColor:"#1affffff"

  onExpandedChanged:if(root.expanded&&root.storageReady){
    root.refreshFiles();
    root.refreshPrinterStatus();
  }

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

  function formatFileSize(bytes){
    let size=Number(bytes);
    let units=["B","KiB","MiB","GiB","TiB","PiB"];
    let unitIndex=0;

    if(!isFinite(size)||size<0)return "? B";

    while(size>=1024&&unitIndex<units.length-1){
      size/=1024;
      unitIndex++;
    }

    if(unitIndex===0)return Math.round(size)+" "+units[unitIndex];
    return size<10?size.toFixed(1)+" "+units[unitIndex]
      :Math.round(size)+" "+units[unitIndex];
  }

  function fileNameFromWebUrl(url) {
    try{
      let parts=url.split('?')[0].split('/');
      let name=parts[parts.length-1];
      return name?decodeURIComponent(name):"downloaded_file";
    }catch(e){
      return "downloaded_file";
    }
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
      "-printf","%s\\t%f\\n"
    ]);
  }

  function enqueueDroppedUrls(urls){
    if(root.printing||!urls||urls.length===0)return;

    if(!storageReady){
      root.pendingDropUrls=root.pendingDropUrls.concat(urls);
      root.lastMessage="Preparing file drawer...";
      return;
    }

    let queue=root.copyQueue.slice();
    let names=[];

    for(let i=0;i<urls.length;i++){
      let rawUrl=typeof urls[i].toString==="function"?urls[i].toString():String(urls[i]);
      let isWeb=rawUrl.startsWith("http://")||rawUrl.startsWith("https://");
      
      let sourcePath="";
      if(!isWeb){
        sourcePath=root.pathFromUrl(urls[i]);
        if(sourcePath===""){
          root.lastMessage="Only local or web files can be copied";
          continue;
        }

        if(sourcePath===root.drawerDirectory||sourcePath.indexOf(root.drawerDirectory+"/")===0){
          continue;
        }
      }

      let originalName=isWeb?root.fileNameFromWebUrl(rawUrl):root.fileNameFromPath(sourcePath);
      if(originalName==="")originalName="downloaded_file";

      let destinationName=root.uniqueName(originalName,names);
      names.push(destinationName);
      
      queue.push({
        source:isWeb?rawUrl:sourcePath,
        name:destinationName,
        destination:root.drawerDirectory+"/"+destinationName,
        isWeb:isWeb
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
    
    if(root.activeCopy.isWeb){
      root.lastMessage="Downloading file";
      copyProcess.exec([
        "curl","-sL",
        "-o",root.activeCopy.destination,
        root.activeCopy.source
      ]);
    }else{
      copyProcess.exec([
        "cp","--",
        root.activeCopy.source,
        root.activeCopy.destination
      ]);
    }
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
        " file"+(root.printFailureCount===1?"":"s")+" couldn't be printed";
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
    root.lastMessage="Stopping print...";

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

  function formatCountdown(totalSeconds){
    let seconds=totalSeconds<0?0:totalSeconds;
    let minutes=Math.floor(seconds/60);
    let remainder=seconds%60;
    return minutes+":"+(remainder<10?"0":"")+remainder;
  }

  // Serve drawerDirectory directly from the fixed share URL.
  function startSharing(){
    if(root.sharing||root.printing||root.files.length===0)return;

    root.qrPath=Quickshell.cachePath("statusbar-share-qr.svg");
    root.shareHost="";
    root.sharePort=0;
    root.shareUrl="";
    root.qrReady=false;
    root.shareStatusMessage="Preparing link...";
    root.sharing=true;

    shareServerProcess.exec([
      "python3","-u","-m","http.server",root.shareListenPort.toString(),
      "--directory",root.drawerDirectory,
      "--bind","0.0.0.0"
    ]);

    hostProcess.exec(["uname","-n"]);
  }

  function stopSharing(){
    if(!root.sharing&&!shareServerProcess.running)return;

    let qrToClean=root.qrPath;
    root.resetShareState("Share stopped");

    if(hostProcess.running)hostProcess.signal(15);
    if(shareServerProcess.running)shareServerProcess.signal(15);
    if(qrProcess.running)qrProcess.signal(15);
    if(qrFileCheckProcess.running)qrFileCheckProcess.signal(15);
    if(qrToClean!=="")shareCleanupProcess.exec(["rm","-f",qrToClean]);
  }

  function resetShareState(message){
    root.sharing=false;
    root.shareUrl="";
    root.qrReady=false;
    root.sharePort=0;
    root.shareHost="";
    shareTimeoutTimer.stop();
    if(message!==undefined)root.shareStatusMessage=message;
  }

  function tryFinalizeShareUrl(){
    if(!root.sharing||root.sharePort===0||root.shareHost==="")return;

    root.shareUrl="http://"+root.shareHost+".local:"+root.sharePort+"/";
    root.shareStatusMessage="Link ready";
    root.shareSecondsLeft=root.shareTimeoutSeconds;
    shareTimeoutTimer.restart();
    root.qrReady=false;
    qrProcess.exec([
      "qrencode","--type=SVG","--output",root.qrPath,root.shareUrl
    ]);
  }

  function handleShareServerLine(line){
    if(!root.sharing||root.sharePort!==0)return;

    let serverLine=String(line).trim();
    let match=serverLine.match(/\bport\s+(\d+)\b/i);
    if(match){
      root.sharePort=parseInt(match[1]);
      root.tryFinalizeShareUrl();
    }
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
        let lines=this.text.trim()===""
          ?[]:this.text.trim().split(/\r?\n/);

        let nextFiles=[];
        for(let i=0;i<lines.length;i++){
          if(lines[i]==="")continue;

          let separator=lines[i].indexOf("\t");
          let size=separator===-1
            ?0:Number(lines[i].substring(0,separator));
          let name=separator===-1
            ?lines[i]:lines[i].substring(separator+1);

          if(name==="")continue;
          nextFiles.push({
            name:name,
            path:root.drawerDirectory+"/"+name,
            size:size
          });
        }

        nextFiles.sort((a,b)=>a.name<b.name?-1:a.name>b.name?1:0);
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
        root.lastMessage=root.copyFailureCount+" file" +(root.copyFailureCount===1?"":"s")+" couldn't be copied";
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
      if(exitCode===0)root.lastMessage="File deleted";
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

  Process{
    id:hostProcess

    stdout:StdioCollector{
      onStreamFinished:{
        root.shareHost=this.text.trim();
        root.tryFinalizeShareUrl();
      }
    }

    onExited:function(exitCode){
      if(exitCode!==0&&root.sharing&&root.shareHost===""){
        root.shareStatusMessage="Could not detect the device hostname";
      }
    }
  }

  // Read the long-running server's startup line as it streams.
  Process{
    id:shareServerProcess

    stdout:SplitParser{
      onRead:(line)=>root.handleShareServerLine(line)
    }

    stderr:SplitParser{
      onRead:(line)=>root.handleShareServerLine(line)
    }

    onExited:function(exitCode){
      let qrToClean=root.qrPath;
      let failedToStart=root.sharing&&root.sharePort===0;

      root.resetShareState(failedToStart
        ?"Could not start the server (is python3 installed?)"
        :"Share stopped");

      if(qrToClean!=="")shareCleanupProcess.exec(["rm","-f",qrToClean]);
    }
  }

  Process{
    id:qrProcess

    stderr:StdioCollector{
      onStreamFinished:{
        let error=this.text.trim();
        if(error!=="")root.shareStatusMessage="Could not generate the QR code (is qrencode installed?)";
      }
    }

    onExited:function(exitCode){
      if(!root.sharing)return;

      if(exitCode!==0){
        root.qrReady=false;
        root.shareStatusMessage="Could not generate the QR code (is qrencode installed?)";
        return;
      }

      qrFileCheckProcess.exec(["test","-s",root.qrPath]);
    }
  }

  Process{
    id:qrFileCheckProcess

    onExited:function(exitCode){
      if(!root.sharing)return;

      root.qrReady=(exitCode===0);
      if(exitCode!==0)
        root.shareStatusMessage="The QR code file was not created";
    }
  }

  Process{id:shareCleanupProcess}

  Timer{
    interval:3000
    running:root.storageReady&&(root.expanded||root.sharing)
    repeat:true
    onTriggered:root.refreshFiles()
  }

  Timer{
    interval:4000
    running:root.storageReady&&(root.expanded||root.printing)
    repeat:true
    onTriggered:root.refreshPrinterStatus()
  }

  Timer{
    id:shareTimeoutTimer
    interval:1000
    repeat:true
    running:false
    onTriggered:{
      root.shareSecondsLeft--;
      if(root.shareSecondsLeft<=0)root.stopSharing();
    }
  }

  Component.onDestruction:{
    if(shareServerProcess.running)shareServerProcess.signal(15);
  }

  collapsedContent:Component{
    Item{
      anchors.fill:parent

      RowLayout{
        anchors.fill:parent
        anchors.leftMargin:10
        anchors.rightMargin:12
        spacing:10

        Rectangle{
          Layout.preferredWidth:30
          Layout.preferredHeight:30
          radius:8
          color:root.printing?"#33f9e2af"
              :root.sharing?"#331793d1"
              :"#1affffff"

          Text{
            anchors.centerIn:parent
            text:root.printing?""
                :root.sharing?"󰐷"
                :"󰈙"
            color:root.printing?"#f9e2af"
                :root.sharing?"#1793d1"
                :"#cdd6f4"
            font.pixelSize:16
          }
        }

        ColumnLayout{
          Layout.fillWidth:true
          spacing:1

          Text{
            Layout.fillWidth:true
            text:root.printing?"Printing"
                :root.sharing?"Sharing"
                :"File drawer"
            color:"#cdd6f4"
            font.pixelSize:12
            font.bold:true
            elide:Text.ElideRight
          }

          Text{
            Layout.fillWidth:true
            text:root.printing
              ?(root.printIndex+" / "+root.printTotal)
             :root.sharing
                ?(root.shareUrl!==""
                ?"Active · "+root.formatCountdown(root.shareSecondsLeft)
                :"Preparing...")
             :(root.files.length+" file"+
               (root.files.length===1?"":"s"))
            color:root.printing?"#f9e2af":root.sharing?"#1793d1":"#a6adc8"
            font.pixelSize:10
            elide:Text.ElideRight
          }
        }

        Rectangle{
          Layout.preferredWidth:7
          Layout.preferredHeight:7
          radius:3.5
          visible:root.printing||root.sharing
          color:root.printing?"#f9e2af":"#a6e3a1"
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
            // verticalLayoutDirection:ListView.BottomToTop
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
                anchors.right:fileSizeText.left
                anchors.rightMargin:4
                anchors.verticalCenter:parent.verticalCenter
                text:"󰈙  "+fileData.name
                color:"#cdd6f4"
                font.pixelSize:10
                elide:Text.ElideRight
              }

              Text{
                id:fileSizeText
                anchors.right:deleteButton.left
                anchors.rightMargin:8
                anchors.verticalCenter:parent.verticalCenter
                text:root.formatFileSize(fileData.size)
                color:"#6c7086"
                font.pixelSize:9
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
           :(root.lastMessage+(root.queuedPrinterJobs>=0?" · Queue:"+root.queuedPrinterJobs:""))
          color:root.printing?"#f9e2af":"#6c7086"
          font.pixelSize:9
          elide:Text.ElideRight
        }

        Rectangle{
          Layout.fillWidth:true
          Layout.maximumWidth:260
          Layout.preferredHeight:Math.min(260,width)
          Layout.alignment:Qt.AlignHCenter
          visible:root.sharing
          radius:6
          color:"#181825"

          Image{
            anchors.fill:parent
            anchors.margins:8
            source:root.qrReady?root.pathToUrl(root.qrPath):""
            fillMode:Image.PreserveAspectFit
            smooth:true
            cache:false
            visible:root.qrReady
          }

          Text{
            anchors.centerIn:parent
            visible:!root.qrReady
            text:"···"
            color:"#181825"
            font.pixelSize:16
            font.bold:true
          }
        }

        RowLayout{
          Layout.fillWidth:true
          spacing:8

          Item{Layout.fillWidth:true}

          Rectangle{
            Layout.preferredWidth:34
            Layout.preferredHeight:34
            radius:17
            color:root.printing||root.copying||root.files.length===0
              ?"#313244":"#1affffff"

            Text{
              anchors.centerIn:parent
              text:"󰆴"
              color:root.printing||root.copying||root.files.length===0
                ?"#6c7086":"#cdd6f4"
              font.pixelSize:17
            }

            TapHandler{
              enabled:!root.printing&&!root.copying&&root.files.length>0
              onTapped:root.clearFiles()
            }
          }

          Rectangle{
            Layout.preferredWidth:34
            Layout.preferredHeight:34
            radius:17
            color:root.printing?"#6c7086":
             (root.files.length>0&&!root.copying?"#1793d1":"#313244")

            Text{
              anchors.centerIn:parent
              text:root.printing?"󰜺":""
              color:root.printing||root.files.length>0?"#11111b":"#6c7086"
              font.pixelSize:17
            }

            TapHandler{
              enabled:root.printing ||(root.files.length>0 && !root.copying)
              onTapped:root.printing?root.cancelPrinting():root.startPrinting()
            }
          }

          Rectangle{
            Layout.preferredWidth:34
            Layout.preferredHeight:34
            radius:17
            color:root.sharing?"#f38ba8"
                :(root.printing||root.copying||root.files.length===0?"#313244":"#1affffff")

            Text{
              anchors.centerIn:parent
              text:root.sharing?"󰅖":"󰐷"
              color:root.sharing?"#11111b"
                  :(root.printing||root.copying||root.files.length===0?"#6c7086":"#cdd6f4")
              font.pixelSize:17
            }

            TapHandler{
              enabled:root.sharing||(!root.printing&&!root.copying&&root.files.length>0)
              onTapped:root.sharing?root.stopSharing():root.startSharing()
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
