syntax off

" set env settings to make me not hate vim
set bg=dark ts=4 sw=4 et is hls cin nocompatible
set ai mouse= nu rnu scs smd ic sc nowrap
set completeopt=menuone,menu,longest,preview lazyredraw

" let vim act differently for different filetypes
filetype on
filetype indent on
filetype plugin on
colo darkblue
syntax on

au CursorMovedI,InsertLEave * if pumvisible() == 0|silent! pclose|endif

" Allow for basic editing changes without mode changes
noremap <space> i<space><esc>
noremap <CR> i<CR><esc>
noremap <C-e> <ESC>

" Draw attention to the current cursor line
set cursorline
hi cursorline cterm=bold ctermbg=238
hi MatchParen cterm=underline ctermbg=brown
hi lineNr ctermfg=grey
hicursorLineNr ctermfg=magenta

" Clear background formatting for search results...Ctrl+l redraws screen
hi Search cterm=NONE ctermfg=black ctermbg=yellow
noremap <silent><C-l> :nohl<CR>

" Jump to front or back of line
noremap  ; $
noremap  f ^
noremap  F 0

" autocomplete curly-braces when in insert mode
inoremap {<CR> {<CR>}<ESC>O

" Shorten the quit process
noremap  <C-d> :qa<CR>
inoremap <C-d> <C-o>:q<CR>
noremap  <C-c> :q!<CR>
inoremap <C-c> <C-o>:q!<CR>

" Make moving up and down a bit more intuitive
noremap  <C-j> <C-e>j
inoremap <C-j> <C-o>j<C-o><C-e>
noremap  <C-k> <C-y>
inoremap <C-k> <C-o>k<C-o><C-y>
noremap  <Up> <C-y>
noremap  <Down> <C-e>

" tab navigation
noremap <F1> gT
inoremap <F1> <C-o>gT
noremap <F2> gt
inoremap <F2> <C-o>gt

" Jump to bottom or top line of screen
noremap  B L
noremap  T H

" Case-insensitive search
noremap \ /\c

if &diff
    colorscheme evening
    set mouse=a
endif
