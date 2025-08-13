syntax off

" Commands to remember:
"  zz   - puts cursorline at middle of screen
"  gg=G - moves to top of file and fixes indenting to the bottom
" <C-R> 0 (prints contents of last deleted/yanked register) to search highlighted text

" set env settings to make me not hate vim
set ts=4 sw=4 softtabstop=4 et incsearch hlsearch cin
set ai mouse=a number relativenumber scs smd ignorecase smartcase
set nowrap lazyredraw nocompatible

filetype on
filetype indent on
filetype plugin on
colo habamax
syntax on

" Draw attention to the current cursor line
set cursorline
hi cursorline cterm=bold ctermbg=238
hi lineNr ctermfg=grey
hi cursorLineNr ctermfg=magenta

" Visual cue when a line is getting long
set colorcolumn=141
hi ColorColumn ctermbg=darkblue

" Other custom highlighting
hi Todo ctermfg=white ctermbg=darkred cterm=bold
hi MatchParen cterm=underline ctermbg=brown

" Setup history file for persistence across sessions
if !isdirectory($HOME."/.vim")
  call mkdir($HOME."/.vim", 0700)
endif
if !isdirectory($HOME."/.vim/undo-dir")
  call mkdir($HOME."/.vim/undo-dir", 0700)
endif
set undodir=~/.vim/undo-dir
set undofile

" Clear background formatting for search results...Ctrl+l redraws screen
hi Search cterm=NONE ctermfg=black ctermbg=yellow
noremap <silent><C-l> :nohl<CR>

" Navigate between beginning and end of a line
noremap ; $
noremap <leader>f 0
noremap F ^

" increment / decrement number under cursor
noremap + <C-a>
noremap - <C-x>

" moving up and down
noremap <C-j> <C-e>j
inoremap <C-j> <C-o>j<C-o><C-e>
noremap <C-k> <C-y>k
inoremap <C-k> <C-o>k<C-o><C-y>

" autocomplete curly-braces when in insert mode
inoremap {<CR> {<CR>}<ESC>O

" Keep search results in the middle of the screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz

" search for what is currently highlighted in visual mode
noremap <C-s> <C-R>0<CR>

" Auto-load cscope DB if present
"   Currently overriding default cscope out to .cscope.out ... findfile dependent on this
function! LoadCscope()
  let db = findfile(".cscope.out", ".;")
  if(!empty(db))
    let path = strpart(db, 0, match(db, "/cscope.out$"))
    set nocscopeverbose
    exe "cs add " . db . " " . path
    set cscopeverbose
  elseif $CSCOPE_DB != ""
    cs add $CSCOPE_DB
  endif
endfunction
au BufEnter /* call LoadCscope()

" don't put the whole path in jumplist - cscope
set cspc=1
nmap <leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <leader>d :vsp <CR>:cs find s <C-R>=expand("<cword>")<CR><CR>

" Allow for basic editing changes without mode changes
noremap <CR> i<CR><esc>
noremap <space> i<space><esc>

command Todo noautocmd vimgrep /TODO\|HILLH/j ** | cw

" I hate trailing whitespace
function! StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    let l_save = winsaveview()
    keep %s/\s\+$//e
    call winrestview(l_save)
  endif
endfunction

command! Trim :call StripTrailingWhitespace()
hi trailingWhitespace ctermbg=red
match trailingWhitespace /\s\+$/

if &diff
  set mouse=a
  windo syntax off
  windo set nospell
  windo set nofoldenable

  hi cursorLine cterm=bold ctermfg=white

  hi DiffAdd ctermbg=darkgreen ctermfg=black
  hi DiffDelete ctermbg=darkred ctermfg=black
  hi DiffChange ctermbg=blue ctermfg=white
  hi DiffText ctermbg=darkblue ctermfg=white
endif
