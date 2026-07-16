import QtQuick
import QtQuick.Layouts

// Usage:
//   ExpandableModule {
//       collapsedContent: Component { YourSmallView {} }
//       expandedContent:  Component { YourDetailView {} }
//       collapsedHeight:  48
//       expandedHeight:   200
//   }
// The collapsed slot is always visible.
// Hovering the module expands it to show the expanded slot below.

Item {
  id: root

  //Public API
  property Component collapsedContent: null
  property Component expandedContent:  null

  property int collapsedHeight: 48
  property int expandedHeight:  160

  property int expandMs:   200
  property int collapseMs: 260

  property color accentColor:     "#4fffffff"
  property color backgroundColor: "#1affffff"

  property bool clickeable:   false
  property bool textOnBottom: false
  property bool hideColapsed: false
  
  //Internal state
  property bool expanded: false

  implicitHeight:expanded
    ?collapsedHeight+expandedHeight
    :collapsedHeight

  Behavior on implicitHeight {
    NumberAnimation {
      duration:root.expanded?root.expandMs:root.collapseMs
      easing.type:Easing.InOutCubic
    }
  }

  Layout.fillWidth:true
  clip:true

  //Background
  Rectangle{
    anchors.fill:parent
    color:root.backgroundColor
    radius:6
  }

  //Hover detection
  HoverHandler{
    onHoveredChanged:if(!root.clickeable)root.expanded=hovered;
  }
  MouseArea{
    anchors.fill:parent
    onClicked:(mouse)=>{
      if(root.clickeable)root.expanded=!root.expanded;
    }
  }

  //Collapsed slot
  Item{
    id: collapsedSlot
    x:0
    y:root.textOnBottom?root.height-root.collapsedHeight:0
    width:  parent.width
    height: root.collapsedHeight

    Loader {
      anchors.fill: parent
      sourceComponent: root.collapsedContent
    }
  }

  //Expanded slot
  Item {
    id:expandedSlot
    x:0
    y:root.textOnBottom 
      ?root.height-root.collapsedHeight-root.expandedHeight 
      :root.collapsedHeight
    width:parent.width
    height:root.expandedHeight
    opacity:root.expanded?1.0:0.0
    visible:opacity>0

    Behavior on opacity{
      NumberAnimation{
        duration:root.expanded?root.expandMs+40:80
        easing.type:Easing.InOutCubic
      }
    }

    Loader{
      anchors.fill:parent
      sourceComponent:root.expandedContent
    }
  }
}

