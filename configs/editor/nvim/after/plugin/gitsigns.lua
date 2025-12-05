-- gitsigns.nvim Configuration
-- Modern Git integration for Neovim (replaces vim-gitgutter)

local ok, gitsigns = pcall(require, 'gitsigns')
if not ok then
  return
end

gitsigns.setup({
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Navigation
    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true, buffer = bufnr, desc = "Next hunk"})

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true, buffer = bufnr, desc = "Prev hunk"})

    -- Actions
    vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', {buffer = bufnr, desc = "Stage hunk"})
    vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', {buffer = bufnr, desc = "Reset hunk"})
    vim.keymap.set('n', '<leader>hS', gs.stage_buffer, {buffer = bufnr, desc = "Stage buffer"})
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, {buffer = bufnr, desc = "Undo stage hunk"})
    vim.keymap.set('n', '<leader>hR', gs.reset_buffer, {buffer = bufnr, desc = "Reset buffer"})
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {buffer = bufnr, desc = "Preview hunk"})
    vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, {buffer = bufnr, desc = "Blame line"})
    vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, {buffer = bufnr, desc = "Toggle blame"})
    vim.keymap.set('n', '<leader>hd', gs.diffthis, {buffer = bufnr, desc = "Diff this"})
    vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, {buffer = bufnr, desc = "Diff this ~"})
    vim.keymap.set('n', '<leader>td', gs.toggle_deleted, {buffer = bufnr, desc = "Toggle deleted"})

    -- Text object
    vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {buffer = bufnr, desc = "Select hunk"})
  end
})

-- Legacy mappings for compatibility (matching old vim-gitgutter behavior)
vim.keymap.set('n', 'gh', function()
  if vim.wo.diff then return 'gh' end
  vim.schedule(function()
    local gs = require('gitsigns')
    if gs then gs.next_hunk() end
  end)
  return '<Ignore>'
end, {expr = true, desc = "Next hunk (legacy)"})

vim.keymap.set('n', 'gH', function()
  if vim.wo.diff then return 'gH' end
  vim.schedule(function()
    local gs = require('gitsigns')
    if gs then gs.prev_hunk() end
  end)
  return '<Ignore>'
end, {expr = true, desc = "Prev hunk (legacy)"})
