" fzf.vim configuration - DISABLED
" fzf.vim plugin has been removed in favor of Telescope
" Use Telescope instead:
"   :Telescope find_files  (replaces :Files)
"   :Telescope buffers    (replaces :Buffers)
"   :Telescope live_grep  (replaces :Find)
"
" Uncomment below if you re-enable fzf.vim:
"
" if executable("highlight")
"   let g:fzf_files_options = '--preview "(highlight -O ansi {-1} || cat {}) 2> /dev/null | head -'.&lines.'"'
" endif
"
" command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
"
" noremap <C-P> :Files<CR>
" noremap <leader>b :Buffers<CR>
" noremap <leader>l :Lines<CR>
