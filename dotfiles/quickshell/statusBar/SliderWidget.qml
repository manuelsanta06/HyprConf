import QtQuick
import QtQuick.Layouts

//common presentation and interaction for level controls
//concrete components handle reading from and writing to the backend
Item{
  id:root

  Layout.fillWidth:true
  implicitHeight:40

  // Disabled while the status bar is hidden to avoid unnecessary backend reads
  property bool active:true

  // Normalized value. The visual bar is always clamped to [0,1].
  property real level:0
  property string icon:""
  property string valueText:Math.round(root.level*100)+"%"

  property color backgroundColor:"#1affffff"
  property color progressColor:"#89b4fa"
  property color iconColor:root.level>root.iconThreshold?"#0f0f14":"#cdd6f4"
  property color valueColor:root.level>root.valueThreshold?"#0f0f14":"#cdd6f4"

  property real iconThreshold:0.15
  property real valueThreshold:0.85
  property int leftMargin:12
  property int rightMargin:12
  property int cornerRadius:8
  property bool secondaryActionEnabled:false

  readonly property real visualLevel:Math.max(0,Math.min(1,root.level))

  signal levelRequested(real level)
  signal secondaryActionRequested()

  function requestLevel(mouse){
    const requestedLevel=Math.max(0,Math.min(1,mouse.x/width));
    root.levelRequested(requestedLevel);
  }

  Rectangle{
    anchors.fill:parent
    color:root.backgroundColor
    radius:root.cornerRadius
    clip:true

    Rectangle{
      width:parent.width*root.visualLevel
      height:parent.height
      color:root.progressColor
      radius:root.cornerRadius

      Behavior on width{
        NumberAnimation{
          duration:150
          easing.type:Easing.OutCubic
        }
      }

      Behavior on color{
        ColorAnimation{duration:200}
      }
    }

    RowLayout{
      anchors.fill:parent
      anchors.leftMargin:root.leftMargin
      anchors.rightMargin:root.rightMargin

      Text{
        text:root.icon
        color:root.iconColor
        font.pixelSize:16

        Behavior on color{
          ColorAnimation{duration:200}
        }
      }

      Item{Layout.fillWidth:true}

      Text{
        text:root.valueText
        color:root.valueColor
        font.pixelSize:11
        font.bold:true

        Behavior on color{
          ColorAnimation{duration:200}
        }
      }
    }

    MouseArea{
      anchors.fill:parent
      preventStealing:true
      acceptedButtons:root.secondaryActionEnabled
        ?Qt.LeftButton|Qt.RightButton
        :Qt.LeftButton

      onPressed:(mouse)=>{
        if(mouse.button===Qt.RightButton){
          root.secondaryActionRequested();
        }else{
          root.requestLevel(mouse);
        }
      }

      onPositionChanged:(mouse)=>{
        if(mouse.buttons&Qt.LeftButton)root.requestLevel(mouse);
      }
    }
  }
}
