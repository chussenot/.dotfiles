-- Telescope Configuration
-- Modern fuzzy finder for Neovim

local ok, telescope = pcall(require, 'telescope')
if not ok then
  return
end

local actions = require('telescope.actions')

telescope.setup({
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
    },
    live_grep = {
      theme = "dropdown",
      -- Only search in files, not in filenames
      only_sort_text = true,
      -- Show preview
      previewer = true,
      -- Better default options
      additional_args = function(opts)
        return { "--hidden" }
      end,
    }
  },
})

-- Load FZF native sorter if available
pcall(telescope.load_extension, 'fzf')

-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Telescope: Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Telescope: Help tags" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope git_status<cr>", { desc = "Telescope: Git status" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope git_commits<cr>", { desc = "Telescope: Git commits" })
