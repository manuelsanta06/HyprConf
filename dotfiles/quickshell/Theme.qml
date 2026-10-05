pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton{
  id:root

  property color background:"#000000"
  property color foreground:"#ffffff"
  property color accent:    "#ffffff"
  property color accentAlt:"#ffffff"

  FileView{
    id:colorsFile

    path:Quickshell.env("HOME")+"/.config/quickshell/theme/matugen.json"

    watchChanges:true

    onFileChanged:reload()

    function applyColors(){
      try{
        const colors=JSON.parse(text())

        root.background = colors.background
        root.foreground = colors.foreground
        root.accent     = colors.accent
        root.accentAlt  = colors.accent_alt

      }catch(error){
        console.log("Theme: error loading colors:",error)
      }
    }

    onLoaded:applyColors()
    onTextChanged:applyColors()
  }
}
