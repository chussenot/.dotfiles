autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()
set foldmethod=manual

au BufEnter * syn match error contained "\<binding.pry\>"
au BufEnter * syn match error contained "\<debugger\>"
