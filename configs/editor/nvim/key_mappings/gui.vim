" vim: syntax=on : filetype=vim:

if has('gui_running')

  " Toggle GVIM toolbars
  function! ToggleToolbars()
    if &guioptions=~#'T'
      set guioptions-=T
    else
      set guioptions+=T
    endif
    if &guioptions=~#'m'
      set guioptions-=m
    else
      set guioptions+=m
    endif

  endfunction
end
