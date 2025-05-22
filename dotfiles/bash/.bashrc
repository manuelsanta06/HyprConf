# ~/.bashrc
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$PATH:$HOME/resources/scripts/"

alias steamopen='xdg-open steam://rungameid/'
alias get_idf='. $HOME/clons/esp-idf/export.sh'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias cls='clear'
alias ln='ln -s'
alias :q='exit'
alias please='sudo'
alias pls='sudo'

export CPLUS_INCLUDE_PATH="/home/santa/librerias"

#PRIN='\e[1;95m'
#NORM='\e[0;37m'
#PS1="[\[${PRIN}\]\u\[${NORM}\]@\e[1;93m\A \e[1;32m$(cat /sys/class/power_supply/BAT0/capacity)%\[${NORM}\]\W]\\$ "

CHARS="󰮯󰊠󱙝󰍳󰛡󰞶󰄛󰩃󰧻󰡚󰣎󰭟󱡂󰊴"
random_char() {
    echo -n "${CHARS:RANDOM % ${#CHARS}:1}"
}

setcolor(){
    if [ -z $1 ] ; then
        echo -n "\\[$(tput sgr0)\\]"
        return 0
    fi
    echo -n "\\[$(tput setaf $1)\\]"
    if [ ! -z $2 ] ; then
        echo -n "\\[$(tput setab $2)\\]"
    fi
}

PS1="$(setcolor 255)$(setcolor 0) $(setcolor 4 0)   $(setcolor 0 4) \$(random_char)  \W $(setcolor;setcolor 4) $(setcolor)"

neofetch
