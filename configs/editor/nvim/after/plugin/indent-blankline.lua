-- indent-blankline.nvim Configuration
-- Visual indent guides

local ok, indent_blankline = pcall(require, 'indent_blankline')
if not ok then
  return
end

indent_blankline.setup({
  char = "│",
  char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
    "IndentBlanklineIndent5",
    "IndentBlanklineIndent6",
  },
  space_char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
    "IndentBlanklineIndent5",
    "IndentBlanklineIndent6",
  },
  show_trailing_blankline_indent = false,
  show_first_indent_level = true,
  use_treesitter = true,
  show_current_context = true,
  show_current_context_start = true,
  context_char = "┃",
  context_highlight_list = {
    "IndentBlanklineContextChar",
    "IndentBlanklineContextStart",
  },
  filetype_exclude = {
    "help",
    "startify",
    "dashboard",
    "packer",
    "neogitstatus",
    "NvimTree",
    "Trouble",
    "TelescopePrompt",
    "TelescopeResults",
    "DiffviewFiles",
    "lspinfo",
    "checkhealth",
    "man",
    "gitcommit",
    "markdown",
    "json",
    "txt",
    "vista_kind",
    "qf",
    "alpha",
    "lir",
    "Outline",
    "spectre_panel",
    "terminal",
  },
  buftype_exclude = {
    "terminal",
    "nofile",
    "quickfix",
    "prompt",
  },
  show_end_of_line = false,
  show_indent_level = false,
})

-- Custom highlight groups for different indent levels
vim.cmd([[
  highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine
  highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine
  highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine
  highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine
  highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine
  highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine
  highlight IndentBlanklineContextChar guifg=#BBBB00 gui=nocombine
  highlight IndentBlanklineContextStart guisp=#BBBB00 gui=underline
]])
