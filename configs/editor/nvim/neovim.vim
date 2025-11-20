" vim: set foldmethod=marker :

" Check if running in NeoVim
if has("nvim")
  " Enable true color support
  set termguicolors
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  set bg=dark

  " Fix for colors in Kitty terminal when termguicolors is set
  " Reference: https://github.com/kovidgoyal/kitty/issues/160#issuecomment-341027936
  let &t_8f = '\e[38;2;%lu;%lu;%lum'
  let &t_8b = '\e[48;2;%lu;%lu;%lum'

  " Terminal mode configurations
  " {{{ Terminal mode
  " Map Escape to switch from terminal to normal mode
  tnoremap <Esc> <C-\><C-n>
  " Allow inserting literal Escape with Ctrl-V -> Escape
  tnoremap <C-v><Esc> <Esc>

  " Highlighting for terminal mode cursor
  highlight! link TermCursor Cursor
  highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
  " }}}

  " Configuration for using neovim-remote within a neovim terminal session
  if executable('nvr')
    let $VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  endif

  " Test strategy configuration (seems to be related to a testing framework)
  let test#strategy = 'neomake'

  " Start Lua block for Treesitter configuration
lua <<EOD
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "c", "clojure", "comment", "css", "dockerfile", "eex",
    "elixir", "elm", "embedded_template", "hcl", "heex", "html",
    "javascript", "json", "lua", "make", "markdown", "regex",
    "ruby", "rust", "vim", "yaml"
  },
  sync_install = false,  -- Do not install parsers synchronously
  highlight = {
    enable = true,  -- Enable syntax highlighting
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,  -- Enable indentation based on Treesitter
  },
  endwise = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,  -- Extend to more syntax elements
    max_file_lines = nil,  -- No limit on file lines for rainbow colors
  },
  matchup = {
    enable = true,  -- Better % navigation
  },
  autotag = {
    enable = true,  -- Auto close and rename HTML tags
  },
}

-- Setup for context-aware comment strings using Treesitter
require('ts_context_commentstring').setup {}
vim.g.skip_ts_context_commentstring_module = true

-- Setup for spell checking with Treesitter
-- DISABLED: spellsitter.nvim has compatibility issues with Neovim 0.11.5
-- The plugin tries to call get_query on nil, causing decoration provider errors
-- TODO: Update spellsitter.nvim or find alternative when compatible version is available
-- vim.defer_fn(function()
--   local ok, spellsitter = pcall(require, 'spellsitter')
--   if ok then
--     spellsitter.setup {
--       enable = true,
--     }
--   else
--     -- Silently fail if spellsitter can't be loaded (compatibility issue)
--     vim.notify("spellsitter: Could not load plugin (compatibility issue)", vim.log.levels.WARN)
--   end
-- end, 100)
EOD

endif  " End of check if running in NeoVim
