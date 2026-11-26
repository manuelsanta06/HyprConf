complete -cf nvrun

# makes pls works as sudo does
_comp_load sudo
complete -F _comp_cmd_sudo pls

_rwallpaper_complete(){
  local dir="$HOME/resources/wallpapers"
  COMPREPLY=($(compgen -W "$(ls -1 "$dir")" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _rwallpaper_complete rWallpaper.sh
