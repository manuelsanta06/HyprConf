# ~/.bashrc
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias WCOUNT='ls -1q /home/santa/resources/wallpapers/ | wc -l'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cls='clear'
alias :q='exit'
alias steamopen='xdg-open steam://rungameid/'
alias ln='ln -s'

export CPLUS_INCLUDE_PATH="/home/santa/librerias"

#PRIN='\e[1;95m'
#NORM='\e[0;37m'
#PS1="[\[${PRIN}\]\u\[${NORM}\]@\e[1;93m\A \e[1;32m$(cat /sys/class/power_supply/BAT0/capacity)%\[${NORM}\]\W]\\$ "

RWALLPAPER(){
    if [ ! -z $1 ]; then
        swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 $(ls /home/santa/resources/wallpapers/$1.* | head -n 1)
    else
        swww img --transition-type outer --transition-pos 0.999,0.999 --transition-step 90 $(ls /home/santa/resources/wallpapers/$((1+$RANDOM%$(WCOUNT))).* | head -n 1)
    fi
}

random_char() {
    CHARS="󰮯󰊠󱙝󰍳󰛡󰞶󰄛󰩃󰧻󰡚󰣎󰭟󱡂󰊴"
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

#PS1="$(setcolor 255)$(setcolor 0) $(setcolor 4 0)   $(setcolor 0 201) \$(cat /sys/class/power_supply/BAT0/capacity)% $(setcolor 4 201)$(setcolor 0 4) \$(random_char)  \W $(setcolor;setcolor 4) $(setcolor)"

neofetch
