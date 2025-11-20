" Telescope Configuration
lua << EOF
local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<esc>"] = actions.close
      },
    },
    file_ignore_patterns = {
      "node_modules",
      ".git/",
      "dist/",
      "build/"
    }
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    }
  },
}

-- Load FZF native sorter if available
pcall(telescope.load_extension, 'fzf')
EOF

" Telescope keymaps
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fs <cmd>Telescope git_status<cr>
nnoremap <leader>fc <cmd>Telescope git_commits<cr>
