import Quickshell
import Quickshell.Hyprland

ShellRoot {
  // Spawn one Bar per screen
  Variants {
    model: Quickshell.screens
    Bar{screen:modelData}
  }
}
