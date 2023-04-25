if has("nvim")
  " Do not run syntastic by default, with neovim, as we'll use neomake
  let g:syntastic_mode_map = { 'mode': 'passive' }
else
  let g:syntastic_enable_signs=1
  let g:syntastic_auto_jump=0
  let g:syntastic_quiet_warnings=0

  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
endif
