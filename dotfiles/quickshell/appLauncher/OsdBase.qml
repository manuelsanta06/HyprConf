import QtQuick
import QtQuick.Layouts

Item{
  id:root
  default property alias content:contentHost.data
  property string position:"right"
  property bool isVertical:position==="left"||position==="right"
  property bool keepOpen:false
  property int hideDelay:1500
  property int animationDuration:400
  property int padding:12
  property color backgroundColor:"#1e1e2e"
  property bool isOsdActive:false

  width:isVertical?300:500
  height:isVertical?500:300

  clip:true
  onKeepOpenChanged:{
    if(keepOpen&&root.state==="visible")hideTimer.stop()
    if(!keepOpen&&root.state==="visible")hideTimer.restart()
  }

  function triggerShow(){
    show()
  }

  function show(){
    root.isOsdActive=true
    root.state="visible"
    if(root.keepOpen)hideTimer.stop()
    else hideTimer.restart()
  }

  function hide(){
    hideTimer.stop()
    root.state="hidden"
  }

  function toggle(){
    if(root.state==="visible")hide()
    else show()
  }

  Timer{
    id:hideTimer
    interval:root.hideDelay
    onTriggered:root.hide()
  }

  Timer{
    id:closeTimer
    interval:root.animationDuration
    running:root.state==="hidden"&&root.isOsdActive
    onTriggered:root.isOsdActive=false
  }

  Rectangle{
    id:contentPanel
    width:parent.width
    height:parent.height
    color:root.backgroundColor

    topLeftRadius:(root.position==="right"||root.position==="bottom")?16:0
    topRightRadius:(root.position==="left"||root.position==="bottom")?16:0
    bottomLeftRadius:(root.position==="right"||root.position==="top")?16:0
    bottomRightRadius:(root.position==="left"||root.position==="top")?16:0

    Item{
      id:contentHost
      anchors.fill:parent
      anchors.margins:root.padding
    }
  }

  state:"hidden"

  states:[
    State{
      name:"visible"
      PropertyChanges{target:contentPanel;x:0;y:0}
    },
    State{
      name:"hidden"
      PropertyChanges{
        target:contentPanel
        x:position==="right"?root.width:(position==="left"?-root.width:0)
        y:position==="bottom"?root.height:(position==="top"?-root.height:0)
      }
    }
  ]

  Behavior on backgroundColor{ColorAnimation{duration:200}}
  transitions:[
    Transition{
      from:"hidden";to:"visible"
      NumberAnimation{properties:"x,y";easing.type:Easing.OutExpo;duration:root.animationDuration}
    },
    Transition{
      from:"visible";to:"hidden"
      NumberAnimation{properties:"x,y";easing.type:Easing.InExpo;duration:root.animationDuration}
    }
  ]
}
