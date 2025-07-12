if has('nvim')
  " Run Neomake when saving any buffer
  augroup localneomake
    autocmd! BufWritePost * Neomake
  augroup END

  " Automatically open the quickfix list on errors, but without moving the
  " cursor from the buffer
  let g:neomake_open_list = 2
endif

let g:neomake_ruby_enabled_makers = ['mri']
let g:neomake_elixir_enabled_makers = ['mix', 'credo']
