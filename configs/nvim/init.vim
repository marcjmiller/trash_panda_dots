" on <Tab> insert 2 spaces
set expandtab

" show existing tabs with 2 spaces, delete 2 spaces on deleting a tab
set tabstop=2
set softtabstop=2

" use 2 spaces width when indenting with >
set shiftwidth=2

" show relative line numbers
set relativenumber

" use auto-indent
set autoindent

" use smart search (case-sensitive if you use an uppercase character)
set ignorecase
set smartcase

" keep 2 lines above/below the cursor
set scrolloff=2

set nocompatible

call plug#begin()

Plug 'sheerun/vim-polyglot'

call plug#end()

