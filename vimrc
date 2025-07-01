syntax off

" Commands to remember:
"  zz   - puts cursorline at middle of screen
"  gg=G - moves to top of file and fixes indenting to the bottom

" set env settings to make me not hate vim
set bg=dark ts=4 sw=4 et is hls cin nocompatible
set ai mouse=a nu rnu scs smd ic sc nowrap lazyredraw

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
" set colorcolumn=81

" Some custom coloring
hi ColorColumn ctermbg=darkblue
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

" Cscope shortcuts
"  CTRL-\ -> find c <under cursor> -> find funcs calling this func
"  CTRL-[ -> find s <under cursor> -> find this symbol
"  CTRL-] -> find g <under cursor> -> find definition of this symbol
nmap <leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <leader>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <leader>f :cs find f <C-R>=expand("<cword>")<CR><CR>
nmap <leader>i :cs find i <C-R>=expand("<cword>")<CR><CR>
nmap <leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>

" Jump to front or back of line
noremap  ; $
noremap  f ^
noremap  F 0

" Allow for basic editing changes without mode changes
noremap <CR> i<CR><esc>
noremap <space> i<space><esc>
noremap <C-e> <ESC>

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

" Copies currently selected text to system clipboard
let @c = ':w !pbcopy'
let @p = ':r !pbpaste'
set clipboard=unnamedplus

" Keep search results in the middle of the screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz

" code folding
set foldmethod=syntax
noremap . za
autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))
set fcs=fold:\ 
augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave ?* mkview
    autocmd BufWinEnter ?* silent loadview
augroup END
command Fold noautocmd set foldlevel=1
command Unfold noautocmd set foldlevel=99

function! CommentLines()
  let l:start = line("'<")
  let l:start = line("'>")
  for l:line in range(l:start, l:end)
    call setline(l:line, '// ' . getline(l:line)
  endfor
endfunction

function! UnCommentLines()
  let l:start = line("'<")
  let l:start = line("'>")
  for l:line in range(l:start, l:end)
    execute l:line . 's@^//\s@@'
  endfor
endfunction

function! CommentLines_Py()
  let l:start = line("'<")
  let l:start = line("'>")
  for l:line in range(l:start, l:end)
    call setline(l:line, '# ' . getline(l:line)
  endfor
endfunction

function! UnCommentLines_Py()
  let l:start = line("'<")
  let l:start = line("'>")
  for l:line in range(l:start, l:end)
    execute l:line . 's@^#\s@@'
  endfor
endfunction


" Block code shortcuts for C/C++ and Python
au BufNewFile,BufRead *.py vnoremap <silent> <leader>c :<C-u>call CommentLines_Py()<CR>
au BufNewFile,BufRead *.py vnoremap <silent> <leader>uc :<C-u>call UnCommentLines_Py()<CR>
au BufNewFile,BufRead *.cpp,*.c,*.h vnoremap <silent> <leader>c :<C-u>call CommentLines()<CR>
au BufNewFile,BufRead *.cpp,*.c,*.h vnoremap <silent> <leader>uc :<C-u>call UnCommentLines()<CR>

command Todo noautocmd vimgrep /TODO\|HILLH/j ** | cw
command Debug noautocmd vimgrep /DEBUG/j ** | cw
