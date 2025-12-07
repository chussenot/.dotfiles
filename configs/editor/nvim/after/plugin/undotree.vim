" Undo configuration is set in vimrc early to avoid incompatible file errors
" This file only provides the undotree keybinding
if has("persistent_undo") && !has("nvim")
  " Only set for Vim (Neovim undo is configured in vimrc)
  set undodir=~/.cache/vim/undo
  call mkdir(&undodir, 'p', 0700)
  set undofile
endif

nnoremap <F6> :UndotreeToggle<CR>
