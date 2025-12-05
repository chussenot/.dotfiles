" Test strategy: use neomake for Neovim (configured in neovim.vim)
" For Vim, dispatch is used as fallback
if !has("nvim")
  let test#strategy = "dispatch"
endif
