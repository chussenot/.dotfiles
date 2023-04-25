""""""""""""""""""""""""""""""""""""""""""""""""""""
"" These were taken straight from the tabular help "
""""""""""""""""""""""""""""""""""""""""""""""""""""

" after/plugin/my_tabular_commands.vim
" Provides extra :Tabularize commands

if !exists(':Tabularize')
finish " Give up here; the Tabular plugin musn't have been loaded
endif

" Make line wrapping possible by resetting the 'cpo' option, first saving it
let s:save_cpo = &cpo
set cpo&vim

AddTabularPattern! asterisk /*/l1

AddTabularPipeline! remove_leading_spaces /^ /
              \ map(a:lines, "substitute(v:val, '^ *', '', '')")

" Restore the saved value of 'cpo'
let &cpo = s:save_cpo
unlet s:save_cpo

""""""""""""""""""""""""""""""""""""""""""""""""""""


" My custom tabular formats
AddTabularPattern after_comma /,\zs
AddTabularPattern after_colon /:\\zs
AddTabularPattern brace /\ {
