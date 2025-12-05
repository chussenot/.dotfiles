-- harpoon Configuration
-- Quick navigation to frequently used files

local ok, harpoon = pcall(require, 'harpoon')
if not ok then
  return
end

harpoon.setup({
  global_settings = {
    -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
    save_on_toggle = false,

    -- saves the harpoon file upon every change. disabling is unrecommended.
    save_on_change = true,

    -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
    enter_on_sendcmd = false,

    -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
    tmux_autoclose_windows = false,

    -- filetypes that you want to prevent from adding to the harpoon list menu.
    excluded_filetypes = { "harpoon" },

    -- set marks specific to each git branch inside git repository
    mark_branch = false,

    -- enable tabline with harpoon marks
    tabline = false,
    tabline_prefix = "   ",
    tabline_suffix = "   ",
  },
})

-- Key mappings
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

-- Add current file to harpoon
vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Harpoon: Add file" })

-- Toggle harpoon menu
vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon: Toggle menu" })

-- Quick navigation to harpoon marks
vim.keymap.set("n", "<leader>h1", function() ui.nav_file(1) end, { desc = "Harpoon: Go to mark 1" })
vim.keymap.set("n", "<leader>h2", function() ui.nav_file(2) end, { desc = "Harpoon: Go to mark 2" })
vim.keymap.set("n", "<leader>h3", function() ui.nav_file(3) end, { desc = "Harpoon: Go to mark 3" })
vim.keymap.set("n", "<leader>h4", function() ui.nav_file(4) end, { desc = "Harpoon: Go to mark 4" })

-- Navigate next/prev in harpoon list
vim.keymap.set("n", "<leader>hn", ui.nav_next, { desc = "Harpoon: Next file" })
vim.keymap.set("n", "<leader>hp", ui.nav_prev, { desc = "Harpoon: Prev file" })
