" These were taken straight from https://github.com/airblade/vim-gitgutter/blob/master/README.mkd
nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk

" We need this if grep is overriden as an alias
" see https://github.com/airblade/vim-gitgutter#use-a-custom-grep-command
if executable("rg")
  " And use rg if avaible, while we're at it
  let g:gitgutter_grep_command = 'rg'
else
  let g:gitgutter_grep_command = 'grep'
endif
