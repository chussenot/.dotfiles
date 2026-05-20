-- Community extensions for claudecode.nvim. These are unaffiliated with
-- Coder and unreleased upstream (no tags) — keep them firewalled behind
-- pcall so any breaking change doesn't take other plugins down with them.
--
--   pittcat/claude-fzf.nvim         — fzf-lua → Claude context shortcuts
--   pittcat/claude-fzf-history.nvim — browse / jump into past sessions
--
-- Both register their own user commands and (when given a keymaps table
-- to setup()) their own keybindings, so the body below is just two setup
-- calls and a which-key prefix label.

local fzf_ok, claude_fzf = pcall(require, 'claude-fzf')
if fzf_ok then
  claude_fzf.setup({
    auto_context = true,
    batch_size   = 10,
    -- Note: <leader>cG instead of the README-suggested <leader>cgf —
    -- otherwise it timeout-conflicts with <leader>cg (grep) and the
    -- grep mapping won't fire until timeoutlen elapses.
    keymaps = {
      files           = '<leader>cf',
      grep            = '<leader>cg',
      buffers         = '<leader>cb',
      git_files       = '<leader>cG',
      directory_files = '<leader>cd',
    },
  })
end

local hist_ok, claude_hist = pcall(require, 'claude-fzf-history')
if hist_ok then
  claude_hist.setup({
    keymaps = {
      history = '<leader>ch',
    },
  })
end

-- Register the <leader>c prefix in which-key so the popup labels the group
-- instead of hanging on a half-typed key.
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
  wk.add({ { '<leader>c', group = 'Claude FZF' } })
end
