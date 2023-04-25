" hide toolbars and menu by default
" (use F10 to toggle back, see key_mappings/gui.vim)
set guioptions-=T
set guioptions-=m

" Highlight wrong spelling
highlight SpellBad term=underline gui=undercurl guisp=Orange

" Color long lines limit
autocmd BufRead,BufNewFile,BufWinEnter * highlight ColorColumn guibg=#222222

" {{{ Load key mappings
exec 'source ' . expand("~/.vim/key_mappings/gui.vim")
" }}}

" Use system clipboard
set clipboard=unnamed

if filereadable(expand("~/.vim/gvimrc.local"))
  exec 'source ' . expand('~/.vim/gvimrc.local')
endif

set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10,DejaVu\ Sans\ Mono\ 10,
