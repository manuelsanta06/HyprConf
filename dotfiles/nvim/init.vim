syntax on

lua require("santa.lazy")

hi Normal guibg=NONE ctermbg=NONE
hi LineNr guifg=#ffffff "guibg=#00ff00
hi LineNrAbove guifg=#ffffff "guibg=#ff0000
hi LineNrBelow guifg=#ffffff "guibg=NONE

set hlsearch                "ni idea 
set relativenumber          "numeros de linea relativos
set number                  "numero de lines
set title                   "ni idea
set shiftwidth=4            "ni idea
set tabstop=4               "tabs de 4 espacios
set expandtab               "los tabs son espacios y no \t
set mouse=a                 "ni idea
set foldmethod=indent       "foldeo en base al indentado
set foldlevel=999           "desfoldea todo
set laststatus=2            "statusbar on

"set statusline=helloworld

set runtimepath+=/home/santa/.local/share/nvim/site
set runtimepath+=/home/santa/.local/share/nvim/site/pack/hig++/

set clipboard+=unnamedplus
"esto hace que la ventana se llame como el archivo
autocmd BufEnter * let &titlestring=expand('%:t')
