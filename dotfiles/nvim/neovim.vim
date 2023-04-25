" vim: set foldmethod=marker :

if has("nvim")
  set termguicolors
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  set bg=dark

  " Fix errors with kitty when termguicolors is set
  " see https://github.com/kovidgoyal/kitty/issues/160#issuecomment-341027936
  let &t_8f = '\e[38;2;%lu;%lu;%lum'
  let &t_8b = '\e[48;2;%lu;%lu;%lum'

  " {{{ Terminal mode
  "
  " Escape to switch back to normal mode
  tnoremap <Esc> <C-\><C-n>
  " Control-V + Escape to insert Escape
  tnoremap <C-v><Esc> <Esc>

  " Highlight terminal mode cursor
  highlight! link TermCursor Cursor
  highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15


  " Use neovim-remote to open main neovim sessions when launching neovim within
  " a neovim terminal session
  " Thanks to https://pragprog.com/book/modvim/modern-vim for the tip!
  "
  " see https://github.com/mhinz/neovim-remote
  " nvr is a tool that helps controlling nvim processes.
  "
  " It does two things:
  "   * adds back the --remote family of options (see man vim)
  "   * helps controlling the current nvim from within :terminal
  if executable('nvr')
    let $VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  endif
  " }}}

  let test#strategy = 'neomake'

lua <<EOD
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
    "bash",
    "c",
    "clojure",
    "comment",
    "css",
    "dockerfile",
    "eex",
    "elixir",
    "elm",
    "embedded_template",
    "hcl",
    "heex",
    "html",
    "javascript",
    "json",
    "lua",
    "make",
    "markdown",
    "regex",
    "ruby",
    "rust",
    "vim",
    "yaml"
    },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
  endwise = {
    enable = true
  },
  rainbow = {
    enable = true,
    -- disabble = {"jsx, "cpp"}
    extended_mode = true,
    max_file_lines = nil
    -- colors = {}
    -- termcolors = {}
  },
  matchup = {
    enable = true
  },
  autotag = {
    enable = true
  },
  context_commentstring = {
    enable = true
  }
}
require('spellsitter').setup {
-- Whether enabled, can be a list of filetypes, e.g. {'python', 'lua'}
  enable = true,
  }
EOD

endif
