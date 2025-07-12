set completefunc=emoji#complete

" Replace emoji name with actual emoji
nnoremap <silent> <Leader><Bslash> :s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g<CR>:noh<CR>
