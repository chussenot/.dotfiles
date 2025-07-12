" vim: syntax=on : filetype=vim foldmethod=marker foldenable :

" set <Leader> to <space>
let mapleader = " "

" <C-c> sends back to normal mode from insert
inoremap <C-c> <Esc>

" Control-L clears search highligtig
" Use <C-L> to clear the search highlighting
" (taken from vim-sensible)
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
"
" Directional keys {{{

" Make linewrap-aware version the default
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" }}}

" INDENTATION {{{
vnoremap < <gv
vnoremap > >gv
" }}}

" TABS {{{

" next tab
map <C-Left>  :tabprevious<CR>

" previous tab
map <C-Right> :tabnext<CR>
" }}}

" BUFFERS {{{

" <leader><leader> switches back to previous buffer
nnoremap <leader><leader> :b#<CR>

" Close current buffer
nnoremap <C-w><C-d> :bd<cr>

" }}}

" SELECTION {{{

" Visually select the text that was last edited/pasted
" see http://vimcasts.org/episodes/bubbling-text
nmap gV `[v`]

" select what you've just pasted
nnoremap gp `[v`]

" single line bubbling
nmap <C-k> [e
nmap <C-j> ]e

" visual selection bubbling
vmap <C-k> [egv
vmap <C-j> ]egv

" }}}

" FOLDING {{{

" use <F8> to open/close a fold
nnoremap <F8> za

" use <Shift-F8> to open/close folds recursively
nnoremap <S-F8> zA

" use <Control-F8> to open all folds
nnoremap <C-F8> zR

" use <Shift-Control-F8> to close all folds
nnoremap <C-S-F8> zM
" }}}

" COLUMN MARKERS {{{
" Use F10 to toggle the highlighting of the current column
noremap <F10> :set cursorcolumn!<CR>
" }}}

" FILE EXPANSION {{{
" Easy Expansion of the Active File Directory
"
" Now when we type %% on Vim’s : command-line prompt, it automatically expands
" to the path of the active buffer, just as though we had typed %:h <Tab>
" taken from Practical Vim
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <expr> $$ getcmdtype() == ':' ? expand('%:f') : '$$'

" Set a binding to insert the current filename
noremap! \fn <C-R>=expand("%")<CR>
" }}}

" {{{ Surroundings
" Surround with parens, braces or brackets in visual mode (courtesty @moa3)
vnoremap ( "zdi(<C-R>z)<ESC>
vnoremap { "zdi{<C-R>z}<ESC>
vnoremap [ "zdi[<C-R>z]<ESC>
vnoremap ' "zdi'<C-R>z'<ESC>
vnoremap " "zdi"<C-R>z"<ESC>
" }}}

" {{{ CONFIG RELOADING

" CTRL-R reloads the ~/.vimrc file
noremap <C-R> call ReloadSource()<CR>

" }}}

" RELATIVE LINE NUMBERING {{{

" Toggle relative line numbering function...
function! ToggleRnu()
  if exists("l:nornu")
    set rnu
  else
    set nu
  end
endfunction
"  and bind it to F11
noremap <silent> <C-F11> :se rnu!<CR>
" }}}

" {{{ COPY AND PASTE
" Toggle paste mode when pasting from elsewhere
nnoremap <F5> :set invpaste paste?<CR>
" }}}

" {{{ MISC

" No more 'Entering Ex mode'
" see http://stackoverflow.com/questions/1269689/to-disable-entering-ex-mode-in-vim
map Q <Nop>

" Write as superuser
command! -bar -nargs=0 W :silent exe "write !sudo tee % >/dev/null"|silent edit!

" }}}
