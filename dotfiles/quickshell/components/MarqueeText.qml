import QtQuick

Item{
  id:root

  property alias text:label.text
  property alias font:label.font
  property alias color:label.color
  property bool active:true
  property real pixelsPerSecond:30
  property int pauseMs:1200
  property int gap:32
  readonly property bool overflowing:width>0&&label.implicitWidth>width

  implicitHeight:label.implicitHeight
  clip:true

  function restart(){
    scroll.stop()
    strip.x=0
    if(active&&visible&&overflowing)scroll.start()
  }

  onActiveChanged:Qt.callLater(root.restart)
  onVisibleChanged:Qt.callLater(root.restart)
  onWidthChanged:Qt.callLater(root.restart)
  Component.onCompleted:Qt.callLater(root.restart)

  Row{
    id:strip
    spacing:root.gap

    Text{
      id:label
      textFormat:Text.PlainText
      wrapMode:Text.NoWrap
      onTextChanged:Qt.callLater(root.restart)
      onImplicitWidthChanged:Qt.callLater(root.restart)
    }

    Text{
      text:label.text
      font:label.font
      color:label.color
      textFormat:Text.PlainText
      wrapMode:Text.NoWrap
      visible:root.overflowing
    }
  }

  SequentialAnimation{
    id:scroll
    loops:Animation.Infinite
    PauseAnimation{duration:root.pauseMs}
    NumberAnimation{
      target:strip
      property:"x"
      from:0
      to:-(label.implicitWidth+root.gap)
      duration:Math.max(1,Math.round((label.implicitWidth+root.gap)/Math.max(1,root.pixelsPerSecond)*1000))
      easing.type:Easing.Linear
    }
    PropertyAction{target:strip;property:"x";value:0}
  }
}
