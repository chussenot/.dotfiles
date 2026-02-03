-- Treesitter configuration
-- This file runs after all plugins are loaded

local ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  -- Silently skip if treesitter not available (run :PlugInstall)
  return
end

treesitter_configs.setup {
  ensure_installed = {
    "bash", "c", "clojure", "comment", "css", "diff", "dockerfile", "eex",
    "elixir", "elm", "embedded_template", "gitcommit", "git_rebase", "hcl",
    "heex", "html", "javascript", "json", "lua", "make", "markdown", "regex",
    "ruby", "rust", "vim", "vimdoc", "yaml"
  },
  sync_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  endwise = {
    enable = true,
  },
  matchup = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}

-- Setup rainbow-delimiters for colorful brackets/parentheses
local ok_rainbow, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
if ok_rainbow then
  vim.g.rainbow_delimiters = {
    strategy = {
      [''] = rainbow_delimiters.strategy['global'],
    },
    query = {
      [''] = 'rainbow-delimiters',
    },
    highlight = {
      'RainbowDelimiterRed',
      'RainbowDelimiterYellow',
      'RainbowDelimiterBlue',
      'RainbowDelimiterOrange',
      'RainbowDelimiterGreen',
      'RainbowDelimiterViolet',
      'RainbowDelimiterCyan',
    },
  }
end

-- Setup context-aware comment strings
local ok_ts_context, ts_context = pcall(require, 'ts_context_commentstring')
if ok_ts_context then
  ts_context.setup {}
  vim.g.skip_ts_context_commentstring_module = true
end
