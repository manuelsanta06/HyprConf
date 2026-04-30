import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property real percentage: 0
    property color accentColor: "#89b4fa" 
    property string icon: ""               
    property string position: "right"     
    property bool isVertical: position === "left" || position === "right"
    // Expose state for PanelWindow visibility
    property bool isOsdActive: false

    width: isVertical?60:300
    height: isVertical?300:60

    clip: true 
    onPercentageChanged: triggerShow()
    onAccentColorChanged: triggerShow()
    onIconChanged: triggerShow()

    function triggerShow() {
        root.isOsdActive = true
        root.state = "visible"
        hideTimer.restart()
    }
    
    Timer{
        id:hideTimer
        interval:3000
        onTriggered:root.state="hidden"
    }

    // Wait for hide animation to finish before hiding window
    Timer{
        id:closeTimer
        interval:400
        running:root.state==="hidden"
        onTriggered:root.isOsdActive=false
    }

    Rectangle{
        id:contentPanel
        width:parent.width
        height:parent.height
        color:"#1e1e2e" 

        topLeftRadius:(root.position==="right"||root.position==="bottom")?16:0
        topRightRadius:(root.position==="left"||root.position==="bottom")?16:0
        bottomLeftRadius:(root.position==="right"||root.position==="top")?16:0
        bottomRightRadius:(root.position==="left"||root.position==="top")?16:0

        Item{
            anchors.fill: parent
            anchors.margins:12
            Text{
                id: iconDisplay
                text: root.icon
                color: "white"
                font.pixelSize: 22
                anchors{
                    left:root.isVertical?undefined:parent.left
                    top:root.isVertical?parent.top:undefined
                    horizontalCenter:root.isVertical?parent.horizontalCenter:undefined
                    verticalCenter:root.isVertical?undefined:parent.verticalCenter
                }
            }
            
            Rectangle {
                id: track
                color: "#313244"
                radius: 4
                anchors {
                    left: isVertical ? parent.left : iconDisplay.right
                    right: isVertical ? parent.right : percentDisplay.left
                    top: isVertical ? iconDisplay.bottom : undefined
                    bottom: isVertical ? percentDisplay.top : undefined
                    verticalCenter: isVertical ? undefined : parent.verticalCenter
                    horizontalCenter: isVertical ? parent.horizontalCenter : undefined
                    
                    leftMargin: isVertical ? 0 : 12
                    rightMargin: isVertical ? 0 : 12
                    topMargin: isVertical ? 12 : 0
                    bottomMargin: isVertical ? 12 : 0
                }
                width: isVertical ? 8 : undefined
                height: isVertical ? undefined : 8
                
                Rectangle {
                    color: root.accentColor
                    radius: 4
                    
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }

                    width: isVertical ? parent.width : (parent.width * (root.percentage / 100))
                    height: isVertical ? (parent.height * (root.percentage / 100)) : parent.height
                    
                    anchors.bottom: isVertical ? parent.bottom : undefined
                    anchors.left: isVertical ? undefined : parent.left
                }
            }
            
            Text {
                id: percentDisplay
                text: Math.round(root.percentage) + "%"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                anchors {
                    right: isVertical ? undefined : parent.right
                    bottom: isVertical ? parent.bottom : undefined
                    horizontalCenter: isVertical ? parent.horizontalCenter : undefined
                    verticalCenter: isVertical ? undefined : parent.verticalCenter
                }
            }
        }
    }
    
    state: "hidden" 
    
    states: [
        State {
            name: "visible"
            PropertyChanges { target: contentPanel; x: 0; y: 0 } 
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: contentPanel
                x: position === "right" ? root.width : (position === "left" ? -root.width : 0)
                y: position === "bottom" ? root.height : (position === "top" ? -root.height : 0)
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"; to: "visible"
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutExpo; duration: 400 }
        },
        Transition {
            from: "visible"; to: "hidden"
            NumberAnimation { properties: "x,y"; easing.type: Easing.InExpo; duration: 400 }
        }
    ]
}
