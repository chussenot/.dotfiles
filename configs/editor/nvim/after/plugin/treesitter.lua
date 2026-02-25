-- Treesitter configuration
-- This file runs after all plugins are loaded

local ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  -- Silently skip if treesitter not available (run :PlugInstall)
  return
end

local wanted = {
  "bash", "c", "clojure", "comment", "css", "diff", "dockerfile", "eex",
  "elixir", "elm", "embedded_template", "gitcommit", "git_rebase", "hcl",
  "heex", "html", "javascript", "json", "lua", "make", "markdown", "regex",
  "ruby", "rust", "vim", "vimdoc", "yaml",
}

-- Remove parsers not in the wanted list to keep :TSUpdate fast
local dominated = pcall(require, 'nvim-treesitter.install')
if dominated then
  local wanted_set = {}
  for _, lang in ipairs(wanted) do wanted_set[lang] = true end
  local installed = require('nvim-treesitter.info').installed_parsers()
  for _, lang in ipairs(installed) do
    if not wanted_set[lang] then
      vim.cmd('silent! TSUninstall ' .. lang)
    end
  end
end

treesitter_configs.setup {
  ensure_installed = wanted,
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
