" see https://github.com/Shougo/neosnippet.vim#configuration
" We won't use <C-K>, since it conflicts with digraph.
imap <C-Y>     <Plug>(neosnippet_expand_or_jump)
smap <C-Y>     <Plug>(neosnippet_expand_or_jump)
xmap <C-Y>     <Plug>(neosnippet_expand_target)

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
