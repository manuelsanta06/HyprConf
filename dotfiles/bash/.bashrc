# ~/.bashrc
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$PATH:$HOME/resources/scripts/"

alias get_idf='. $HOME/clons/esp-idf/export.sh; alias idf="idf.py";alias build="time idf.py build"; alias fullclean="idf.py fullclean"'
alias log="git log --all --decorate --oneline --graph"
alias steamopen='xdg-open steam://rungameid/'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias neo='neofetch'
alias cls='clear'
alias please='sudo'
alias pls='sudo'
alias ln='ln -s'
alias :q='exit'

export CPLUS_INCLUDE_PATH="/home/santa/librerias"

#PRIN='\e[1;95m'
#NORM='\e[0;37m'
#PS1="[\[${PRIN}\]\u\[${NORM}\]@\e[1;93m\A \e[1;32m$(cat /sys/class/power_supply/BAT0/capacity)%\[${NORM}\]\W]\\$ "

CHARS="󰮯󰊠󱙝󰍳󰛡󰞶󰄛󰩃󰧻󰡚󰣎󰭟󱡂󰊴"

random_char() {
    echo -n "${CHARS:RANDOM % ${#CHARS}:1}"
}

setcolor() {
    # Restablecer colores si no hay argumentos
    if [ -z "$1" ]; then
        echo -n "$(tput sgr0)"
        return 0
    fi
    # Validar que los argumentos sean números
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Error: El primer argumento debe ser un número (color de texto)." >&2
        return -1
    fi

    echo -n "$(tput setaf "$1")"

    if [ -n "$2" ]; then
        if ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "Error: El segundo argumento debe ser un número (color de fondo)." >&2
            return -1
        fi
        echo -n "$(tput setab "$2")"
    fi
}


GIT_PROMPT(){
    [[  "$ON_GIT_REPO" == "true" ]] && echo "$(setcolor 0 202)$(setcolor 0 202) ${GIT_BRANCH} $(setcolor 4 202)" || echo "$(setcolor 0 4)"
    #${DIVISORS[$PAR]}
}
ON_GIT_REPO=""
GIT_BRANCH=""
PROMPT_COMMAND='GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);GIT_BRANCH="$(GIT_PROMPT)";ON_GIT_REPO="$(git rev-parse --is-inside-work-tree 2> /dev/null)";'
PS1="$(setcolor 255)$(setcolor 0) $(setcolor 4 0)   \${GIT_BRANCH}$(setcolor 0 4) \$(random_char)  \W $(setcolor;setcolor 4) $(setcolor)"

neofetch
