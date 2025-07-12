if exists('g:GtkGuiLoaded')

  " Enable pasting with Shift-Insert
  " see https://github.com/daa84/neovim-gtk/issues/14
  map <S-Insert> "*gP
  cmap <S-Insert> <C-R>*
  imap <S-Insert> <C-R>*

  " Enable native gtk clipboard support
  let g:GuiInternalClipboard = 1

endif

if filereadable(expand("~/.vim/ginit.vim.local"))
  exec 'source ' . expand('~/.vim/ginit.vim.local')
endif
