-- nvim-spectre Configuration
-- Search and replace across files

local ok, spectre = pcall(require, 'spectre')
if not ok then
  return
end

spectre.setup({
  mapping = {
    ['toggle_line'] = {
      map = "dd",
      cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      desc = "toggle current item",
    },
    ['enter_file'] = {
      map = "<cr>",
      cmd = "<cmd>lua require('spectre').open_file(false)<CR>",
      desc = "open file",
    },
    ['send_to_qf'] = {
      map = "<leader>q",
      cmd = "<cmd>lua require('spectre').send_to_qf()<CR>",
      desc = "send all item to quickfix",
    },
    ['replace_cmd'] = {
      map = "<leader>c",
      cmd = "<cmd>lua require('spectre').replace_cmd()<CR>",
      desc = "replace command",
    },
    ['show_option_menu'] = {
      map = "<leader>o",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show option",
    },
    ['run_replace'] = {
      map = "<leader>R",
      cmd = "<cmd>lua require('spectre').run_replace()<CR>",
      desc = "replace all",
    },
    ['change_view_mode'] = {
      map = "<leader>v",
      cmd = "<cmd>lua require('spectre').change_view()<CR>",
      desc = "change result view mode",
    },
    ['toggle_live_update'] = {
      map = "tu",
      cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
      desc = "update change when vim write file.",
    },
    ['toggle_ignore_case'] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "toggle ignore case",
    },
    ['toggle_ignore_hidden'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "toggle ignore hidden",
    },
    -- you can put your mapping here it only use normal mode
  },
})

-- Key mappings
vim.keymap.set("n", "<leader>S", function() spectre.open() end, { desc = "Spectre: Open search" })
vim.keymap.set("n", "<leader>sw", function() spectre.open_visual({select_word=true}) end, { desc = "Spectre: Search word under cursor" })
vim.keymap.set("v", "<leader>sw", function() spectre.open_visual() end, { desc = "Spectre: Search selection" })
