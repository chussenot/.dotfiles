if has("persistent_undo")
  " Use Neovim cache directory if available, fallback to vim cache
  if has("nvim")
    set undodir=~/.cache/nvim/undo
  else
    set undodir=~/.cache/vim/undo
  endif
  " Create directory if it doesn't exist
  call mkdir(&undodir, 'p', 0700)
  set undofile
endif

nnoremap <F6> :UndotreeToggle<CR>
