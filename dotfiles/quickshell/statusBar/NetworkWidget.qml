import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Networking
import "../components"
pragma ComponentBehavior:Bound

ExpandableModule{
  id:netWidget

  textOnBottom:true
  collapsedHeight:45
  expandedHeight:Math.min(320,94+
    Math.max(1,Math.min(netWidget.visibleNetworks.length,6))*36+
    (netWidget.passwordRequired?40:0))
  clickeable:true

  property bool active:false
  property var devices:Networking.devices.values
  property var wifiDevice:findWifiDevice()
  property var activeDevice:findActiveDevice()
  property var activeNetwork:findActiveNetwork(netWidget.activeDevice)
  property string ssid:netWidget.activeNetwork
    ?netWidget.activeNetwork.name
    :(netWidget.activeDevice?netWidget.activeDevice.name:"Disconnected")
  property string type:netWidget.activeDevice&&
    netWidget.activeDevice.type===DeviceType.Wired?"ethernet":"wifi"
  property int strength:netWidget.activeNetwork&&netWidget.type==="wifi"
    ?Math.round(netWidget.activeNetwork.signalStrength*100)
    :netWidget.activeDevice?100:0
  property string accent:netWidget.activeDevice?"#1793d1":"#ff0000"
  property var selectedNetwork:null
  property string connectionMessage:""
  property string passwordText:""
  property bool passwordRequired:false
  property int networkRevision:0
  property var visibleNetworks:{
    let revision=netWidget.networkRevision;
    let values=netWidget.wifiDevice
      ?netWidget.wifiDevice.networks.values:[];
    let result=[];

    for(let i=0;i<values.length;i++)
      result.push(values[i]);

    result.sort((a,b)=>b.signalStrength-a.signalStrength);
    return result;
  }

  function findWifiDevice(){
    for(let i=0;i<netWidget.devices.length;i++)
      if(netWidget.devices[i].type===DeviceType.Wifi)return netWidget.devices[i];
    return null;
  }

  function findActiveDevice(){
    for(let i=0;i<netWidget.devices.length;i++)
      if(netWidget.devices[i].connected)return netWidget.devices[i];
    return null;
  }

  function findActiveNetwork(device){
    if(!device)return null;
    if(device.type===DeviceType.Wired)return device.network;

    let networks=device.networks.values;
    for(let i=0;i<networks.length;i++)
      if(networks[i].connected)return networks[i];
    return null;
  }

  function getIcon(){
    if(netWidget.ssid==="Disconnected")return "󱍢";
    if(netWidget.type==="ethernet")return "󰈀";
    if(netWidget.strength<25)return "󰤟";
    if(netWidget.strength<50)return "󰤢";
    if(netWidget.strength<75)return "󰤥";
    return "󰤨";
  }

  function supportsPsk(network){
    return network.security===WifiSecurityType.WpaPsk||
      network.security===WifiSecurityType.Wpa2Psk||
      network.security===WifiSecurityType.Sae;
  }

  function securityLabel(network){
    return network.security===WifiSecurityType.Open?"Open":"Locked";
  }

  function refresh(){
    if(!netWidget.wifiDevice)return;

    netWidget.wifiDevice.scannerEnabled=false;
    netWidget.wifiDevice.scannerEnabled=true;
    netWidget.networkRevision++;
  }

  function selectNetwork(network){
    if(!network||network.stateChanging)return;

    netWidget.selectedNetwork=network;
    netWidget.passwordText="";
    netWidget.passwordRequired=false;

    if(network.connected){
      netWidget.connectionMessage="Connected";
      return;
    }

    if(network.known||network.security===WifiSecurityType.Open){
      netWidget.connectionMessage="Connecting...";
      network.connect();
      return;
    }

    if(netWidget.supportsPsk(network)){
      netWidget.connectionMessage="Password required";
      netWidget.passwordRequired=true;
    }else{
      netWidget.connectionMessage="Use nmtui for this security type";
    }
  }

  function connectSelected(){
    if(!netWidget.selectedNetwork||netWidget.passwordText==="")return;

    netWidget.connectionMessage="Connecting...";
    netWidget.selectedNetwork.connectWithPsk(netWidget.passwordText);
    netWidget.passwordText="";
    netWidget.passwordRequired=false;
  }

  onActiveChanged:{
    if(netWidget.active&&netWidget.expanded){
      netWidget.refresh();
    }else{
      if(netWidget.wifiDevice)
        netWidget.wifiDevice.scannerEnabled=false;
    }
  }

  onExpandedChanged:{
    if(netWidget.expanded&&netWidget.active){
      netWidget.refresh();
    }else if(netWidget.wifiDevice){
      netWidget.wifiDevice.scannerEnabled=false;
    }
  }
  onWifiDeviceChanged:if(netWidget.active&&netWidget.expanded)netWidget.refresh()

  Connections{
    target:netWidget.wifiDevice?netWidget.wifiDevice.networks:null
    function onValuesChanged(){netWidget.networkRevision++}
  }

  Connections{
    target:netWidget.selectedNetwork
    function onConnectedChanged(){
      if(netWidget.selectedNetwork&&netWidget.selectedNetwork.connected){
        netWidget.connectionMessage="Connected";
        netWidget.passwordRequired=false;
      }
    }
    function onConnectionFailed(reason){
      netWidget.connectionMessage=ConnectionFailReason.toString(reason);
      if(reason===ConnectionFailReason.NoSecrets&&
        netWidget.supportsPsk(netWidget.selectedNetwork))
        netWidget.passwordRequired=true;
    }
  }

  Process{id:cmdRunner}

  collapsedContent:Component{
    RowLayout{
      anchors.fill:parent
      anchors.leftMargin:16
      anchors.rightMargin:16
      spacing:12

      Text{
        text:netWidget.getIcon()
        font.pixelSize:18
        color:netWidget.ssid!=="Disconnected"?netWidget.accent:"#f38ba8"
        TapHandler{
          id:tapHandler
          onTapped:cmdRunner.exec(["kitty","nmtui"])
        }
      }

      Text{
        Layout.fillWidth:true
        text:netWidget.ssid
        color:"#cdd6f4"
        font.pixelSize:13
        font.bold:true
        elide:Text.ElideRight
      }
    }
  }

  expandedContent:Component{
    ColumnLayout{
      anchors.fill:parent
      anchors.margins:8
      spacing:5

      RowLayout{
        Layout.fillWidth:true
        Layout.preferredHeight:28

        Text{
          Layout.fillWidth:true
          text:"Available networks"
          color:"#cdd6f4"
          font.pixelSize:13
          font.bold:true
        }

        Rectangle{
          Layout.preferredWidth:30
          Layout.preferredHeight:28
          radius:4
          color:hover.hovered?"#331793d1":"transparent"

          Text{
            anchors.centerIn:parent
            text:"󰑐"
            color:"#cdd6f4"
            font.pixelSize:17
          }

          HoverHandler{id:hover}
          TapHandler{onTapped:netWidget.refresh()}
        }
      }

      Text{
        Layout.fillWidth:true
        visible:netWidget.connectionMessage!==""
        text:netWidget.connectionMessage
        color:"#a6adc8"
        font.pixelSize:11
        elide:Text.ElideRight
      }

      RowLayout{
        Layout.fillWidth:true
        Layout.preferredHeight:30
        visible:netWidget.passwordRequired

        Rectangle{
          Layout.fillWidth:true
          Layout.fillHeight:true
          radius:4
          color:"#22181825"
          border.color:"#313244"
          border.width:1

          TextInput{
            anchors.fill:parent
            anchors.leftMargin:8
            anchors.rightMargin:8
            text:netWidget.passwordText
            color:"#cdd6f4"
            font.pixelSize:12
            echoMode:TextInput.Password
            clip:true
            onTextChanged:netWidget.passwordText=text
            onVisibleChanged:if(visible){clear();forceActiveFocus()}
            Keys.onReturnPressed:netWidget.connectSelected()
          }
        }

        Rectangle{
          Layout.preferredWidth:58
          Layout.fillHeight:true
          radius:4
          color:"#331793d1"

          Text{
            anchors.centerIn:parent
            text:"Connect"
            color:"#cdd6f4"
            font.pixelSize:11
          }

          TapHandler{onTapped:netWidget.connectSelected()}
        }
      }

      ListView{
        id:networkList
        Layout.fillWidth:true
        Layout.fillHeight:true
        clip:true
        spacing:4
        model:netWidget.visibleNetworks

        delegate:Rectangle{
          required property var modelData
          width:networkList.width
          height:32
          radius:4
          color:modelData.connected?"#331793d1":"#12181825"

          RowLayout{
            anchors.fill:parent
            anchors.leftMargin:8
            anchors.rightMargin:8
            spacing:8

            Text{
              Layout.fillWidth:true
              text:modelData.name
              color:"#cdd6f4"
              font.pixelSize:12
              elide:Text.ElideRight
            }

            Text{
              text:modelData.known?"󰌾":netWidget.securityLabel(modelData)
              color:modelData.known?"#a6adc8":"#6c7086"
              font.pixelSize:modelData.known?13:10
            }

            Text{
              text:Math.round(modelData.signalStrength*100)+"%"
              color:"#a6adc8"
              font.pixelSize:11
            }
          }

          TapHandler{
            enabled:!modelData.stateChanging
            onTapped:netWidget.selectNetwork(modelData)
          }
        }

        Text{
          anchors.centerIn:parent
          visible:netWidget.visibleNetworks.length===0
          text:netWidget.wifiDevice?"No networks found":"No Wi-Fi device"
          color:"#6c7086"
          font.pixelSize:12
        }
      }
    }
  }
}
