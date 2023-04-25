if has("persistent_undo")
  set undodir=~/.cache/vim/undo
  set undofile
endif

nnoremap <F6> :UndotreeToggle<CR>
