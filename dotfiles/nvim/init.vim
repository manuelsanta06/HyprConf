syntax on

lua require("santa.lazy")


hi Normal guibg=NONE ctermbg=NONE           " ventana activa
hi NormalNC guibg=NONE ctermbg=NONE         " ventana inactiva
hi EndOfBuffer guibg=NONE ctermbg=NONE      " líneas vacías
hi VertSplit guibg=NONE ctermbg=NONE        " división vertical
hi StatusLine guibg=NONE ctermbg=NONE       " barra estado
hi StatusLineNC guibg=NONE ctermbg=NONE     " estado inactiva
hi SignColumn guibg=NONE ctermbg=NONE       " columna signos
hi TabLine guibg=NONE ctermbg=NONE          " línea pestañas
hi TabLineFill guibg=NONE ctermbg=NONE      " fondo pestañas
hi TabLineSel guibg=NONE ctermbg=NONE       " pestaña activa
hi FloatBorder guibg=NONE ctermbg=NONE      " borde flotante
hi NormalFloat guibg=NONE ctermbg=NONE      " ventana flotante
hi StatusLine guibg=#8f00ff guifg=#ffffff   " barra activa
hi StatusLineNC guibg=#1e1e1e guifg=#ffffff " barra inactiva

hi LineNr guifg=#ffffff "guibg=#00ff00
hi LineNrAbove guifg=#ffffff "guibg=#ff0000
hi LineNrBelow guifg=#ffffff "guibg=NONE

set hlsearch                                " ni idea 
set relativenumber                          " numeros de linea relativos
set number                                  " numero de lines
set title                                   " ni idea
set shiftwidth=2                            " ni idea
set tabstop=2                               " tabs de 4 espacios
set expandtab                               " los tabs son espacios y no \t
set mouse=a                                 " ni idea
set foldmethod=indent                       " foldeo en base al indentado
set foldlevel=999                           " desfoldea todo
set laststatus=2                            " statusbar on

"set statusline=helloworld

nnoremap <C-S-e> :Neotree toggle<CR>  " Ctrl+Shift+E abre/cierra Neo-tree

set runtimepath+=/home/santa/.local/share/nvim/site
set runtimepath+=/home/santa/.local/share/nvim/site/pack/hig++/

set clipboard+=unnamedplus
"esto hace que la ventana se llame como el archivo
autocmd BufEnter * let &titlestring=expand('%:t')
