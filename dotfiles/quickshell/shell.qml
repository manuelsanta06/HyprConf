import QtQuick
import Quickshell

import "statusBar" as Bar
import "appLauncher" as Launcher
import "osd" as Osd

ShellRoot{
  Bar.StatusBar{}
  Launcher.AppLauncher{}
  Osd.AllOsd{}
}
