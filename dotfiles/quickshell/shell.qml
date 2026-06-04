import QtQuick
import Quickshell

import "statusBar" as Bar
import "appLauncher" as Launcher
import "osd" as Osd
import "notifications" as Noti

ShellRoot{
  Bar.StatusBar{}
  Launcher.AppLauncher{}
  Osd.AllOsd{}
  Noti.Minecraft{}
}
