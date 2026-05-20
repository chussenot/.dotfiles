-- claudecode.nvim — Claude Code integration via the MCP WebSocket protocol.
-- https://github.com/coder/claudecode.nvim
--
-- The plugin spins up an RFC 6455 WebSocket server inside Neovim and writes
-- a lock file under ~/.claude/ide/. The external `claude` CLI auto-discovers
-- that lock file and connects, so Claude can read your buffers, propose
-- diffs, and run terminal commands inside an embedded split.

local ok, claudecode = pcall(require, 'claudecode')
if not ok then return end

-- snacks.nvim is the terminal provider we use. Must call setup() — just
-- `require`ing the module is not enough; `:checkhealth snacks` will
-- complain "setup not called" and the terminal provider won't work.
-- Empty opts uses snacks' conservative defaults (no auto-enabled UI
-- replacements beyond what's needed for the terminal split).
local snacks_ok, snacks = pcall(require, 'snacks')
if snacks_ok then snacks.setup({}) end

claudecode.setup({
  -- Where the embedded terminal opens. Right-side split is least disruptive
  -- to NERDTree on the left.
  terminal = {
    split_side             = 'right',
    split_width_percentage = 0.35,
    provider               = 'snacks',
  },
  -- Show diffs vertically — matches the rest of the workflow (delta, tig).
  diff_opts = {
    layout          = 'vertical',
    open_in_new_tab = false,
  },
})

-- Keymaps. Sticking to the README-recommended `<leader>a*` prefix; `a` for
-- "AI" so it doesn't collide with existing `<leader>` mappings.
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map('n', '<leader>ac', '<cmd>ClaudeCode<cr>',             'Claude: toggle terminal')
map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>',        'Claude: focus terminal')
map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>',    'Claude: resume last session')
map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>',  'Claude: continue (no prompt)')
map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>',  'Claude: pick model')
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',        'Claude: add current buffer as context')
map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>',         'Claude: send selection as context')
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>',   'Claude: accept proposed diff')
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>',     'Claude: deny proposed diff')

-- Surface the prefix in which-key so `<leader>a` opens a discoverable popup
-- rather than hanging waiting for the second key.
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
  -- which-key v3 spec.
  wk.add({ { '<leader>a', group = 'AI / Claude Code' } })
end
