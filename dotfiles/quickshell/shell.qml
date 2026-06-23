import QtQuick
import QtQml
import Quickshell

import "statusBar" as Bar
import "appLauncher" as Launcher
import "osd" as Osd
import "notifications" as Noti

ShellRoot{
  Instantiator{
    model:Quickshell.screens
    delegate:Bar.StatusBar{}
  }
  Launcher.AppLauncher{}
  Osd.AllOsd{}
  Noti.Minecraft{}
}
