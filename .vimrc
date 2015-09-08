set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set nowrap

syntax on

set relativenumber
set numberwidth=2
highlight LineNr term=bold cterm=NONE ctermfg=151  ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

set undofile
set undodir=~/.vimundo/

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

