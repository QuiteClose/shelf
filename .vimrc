" Code indentation
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set nowrap

" Syntax highlighting
syntax on

" Relative Line numbering
set relativenumber
set numberwidth=2
highlight LineNr term=bold cterm=NONE ctermfg=151  ctermbg=NONE gui=NONE guifg=DarkGray guibg=NONE

" Persist undo history between file edits
set undofile
set undodir=~/.vimundo/

" Allow F2 key to toggle paste mode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

