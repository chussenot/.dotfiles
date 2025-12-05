" see https://medium.com/@crashybang/supercharge-vim-with-fzf-and-ripgrep-d4661fc853d2#.loxgy7s44
"
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options

" Note: fzf_launcher removed - urxvt is outdated, fzf works fine without it

if executable("highlight")
  let g:fzf_files_options = '--preview "(highlight -O ansi {-1} || cat {}) 2> /dev/null | head -'.&lines.'"'
endif

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)

noremap <C-P> :Files<CR>
noremap <leader>b :Buffers<CR>
noremap <leader>l :Lines<CR>
