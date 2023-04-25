" Close fugitive buffers when we are done with them
" See http://mixandgo.com/blog/vim-config-for-rails-ninjas
autocmd BufReadPost fugitive://* set bufhidden=delete

" Use <F9> to open Git status and diff
" see http://vimcasts.org/episodes/fugitive-vim-working-with-the-git-index/
nmap <F9> :Gstatus<ESC><C-W><C-W>:Gdiff<CR>
