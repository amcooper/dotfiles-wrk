" Make backspace behave in a sane manner.
set backspace=indent,eol,start

" Configure the clipboard to access the \"+ and \"* registers
" (not sure why I need this now and didn't before)
set clipboard=unnamedplus,unnamed

" Spaces indentation
set expandtab
set tabstop=2
" set softtabstop=2
set shiftwidth=2
" Consider installing the Smart Tabs plugin

" Show whitespace
set listchars=eol:¬,tab:>-,trail:~,extends:>,precedes:<,space:·

" Show line numbers
set number

" Default: split right
set splitright

" Highlight cursor line
set cursorline

" Allow hidden buffers, don't limit to one file per window/split
set hidden

" Enable folding
set foldmethod=indent
set foldlevel=99

" Sane vim split naviagation (via Gaslight blog)
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Disable filetype detection
filetype off

" Adjust cursor style to mode
" Normal: block; Insert: beam; Replace: underscore
" all blinking
let &t_EI = "\<Esc>[1 q"
let &t_SI = "\<Esc>[5 q"
let &t_SR = "\<Esc>[3 q"
" reset the cursor on start
augroup CursorReset
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

" Indentation for Python - throws error, needs fixing
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

" Flag extraneous whitespace - throws error, needs fixing
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

set encoding=utf-8

" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'dense-analysis/ale'
Plug 'Valloric/YouCompleteMe'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'vim-scripts/indentpython.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'kovisoft/slimv'
call plug#end()

" Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1

" ALE
let g:ale_linters = {
      \ 'haskell': ['hlint', 'hdevtools'],
\}

nnoremap <F7> :ALEFindReferences<CR>

" YouCompleteMe
nnoremap <F8> :YcmCompleter GoTo<CR>

" YouCompleteMe <> TypeScript
if !exists("g:ycm_semantic_triggers")
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers['typescript'] = ['.']

" Enable file type detection and do language-dependent indenting
filetype plugin indent on

" Switch syntax highlighting on
syntax enable

" Set color scheme
set background=dark
colorscheme dracula

" Temporary file locations
set backupdir=.backup/,~/.backup/,/tmp//
set directory=.swp/,~/.swp/,/tmp//
set undodir=.undo/,~/.undo/,/tmp//
