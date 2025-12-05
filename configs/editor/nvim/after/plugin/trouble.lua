-- trouble.nvim Configuration
-- Better diagnostics display for LSP, linters, etc.

local ok, trouble = pcall(require, 'trouble')
if not ok then
  return
end

trouble.setup({
  mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
  group = true, -- group results by file
  padding = true, -- add an extra new line on top of the list
  action_keys = {
    -- map to {} to remove a mapping, for example:
    -- close = {},
    close = "q", -- close the list
    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
    refresh = "r", -- manually refresh
    jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
    open_split = { "<c-x>" }, -- open buffer in new split
    open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
    open_tab = { "<c-t>" }, -- open buffer in new tab
    jump_close = { "o" }, -- jump to the diagnostic and close the list
    toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
    switch_severity = "s", -- switch "diagnostics severity" filter level (HINT / INFO / WARN / ERROR)
    toggle_preview = "P", -- toggle auto_preview
    hover = "K", -- opens a small popup with the full multiline message
    preview = "p", -- preview the diagnostic location
    close_folds = { "zM", "zm" }, -- close all folds
    open_folds = { "zR", "zr" }, -- open all folds
    toggle_fold = { "za", "zA" }, -- toggle fold of current file
    previous = "k", -- previous item
    next = "j", -- next item
    help = "?", -- help menu
  },
  indent_lines = true, -- add an indent guide below the fold icons
  auto_open = false, -- automatically open the list when you have diagnostics
  auto_close = false, -- automatically close the list when you have no diagnostics
  auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
  auto_fold = false, -- automatically fold a file trouble list at creation
  auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
  signs = {
    -- icons / text used for a diagnostic
    error = "✗",
    warning = "⚠",
    hint = "➤",
    information = "ℹ",
    other = "•",
  },
  use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
})

-- Key mappings
vim.keymap.set("n", "<leader>xx", function() trouble.toggle() end, { desc = "Trouble: Toggle" })
vim.keymap.set("n", "<leader>xw", function() trouble.toggle("workspace_diagnostics") end, { desc = "Trouble: Workspace diagnostics" })
vim.keymap.set("n", "<leader>xd", function() trouble.toggle("document_diagnostics") end, { desc = "Trouble: Document diagnostics" })
vim.keymap.set("n", "<leader>xq", function() trouble.toggle("quickfix") end, { desc = "Trouble: Quickfix" })
vim.keymap.set("n", "<leader>xl", function() trouble.toggle("loclist") end, { desc = "Trouble: Location list" })
vim.keymap.set("n", "<leader>xr", function() trouble.toggle("lsp_references") end, { desc = "Trouble: LSP references" })
