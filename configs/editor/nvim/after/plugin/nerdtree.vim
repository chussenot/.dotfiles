" NERDTree configuration
" Only set up if NERDTree is actually loaded
if exists(":NERDTreeToggle") == 2
  nnoremap <silent> <C-T> :NERDTreeToggle<CR>

  " Only add custom keymap if NERDTree API is available
  if exists("*NERDTreeAddKeyMap")
    if !exists("g:loaded_nerdree_live_preview_mapping")
      let g:loaded_nerdree_live_preview_mapping = 1

      call NERDTreeAddKeyMap({
            \ 'key':           'v',
            \ 'callback':      'NERDTreeLivePreview',
            \ 'quickhelpText': 'preview',
            \ })

      function! NERDTreeLivePreview()
        " Get the path of the item under the cursor if possible:
        let current_file = g:NERDTreeFileNode.GetSelected()

        if current_file == {}
          return
        else
          exe 'botright pedit '.current_file.path.str()
        endif
      endfunction
    endif
  endif
endif
