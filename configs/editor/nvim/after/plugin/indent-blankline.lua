-- indent-blankline.nvim Configuration (v3)
-- Visual indent guides
-- Migrated to version 3 API

local ok, ibl = pcall(require, 'ibl')
if not ok then
  return
end

-- Define custom highlight groups using hooks (v3 API)
local hooks_ok, hooks = pcall(require, 'ibl.hooks')
if hooks_ok then
  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "IblIndent1", { fg = "#E06C75", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent2", { fg = "#E5C07B", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent3", { fg = "#98C379", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent4", { fg = "#56B6C2", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent5", { fg = "#61AFEF", nocombine = true })
    vim.api.nvim_set_hl(0, "IblIndent6", { fg = "#C678DD", nocombine = true })
    vim.api.nvim_set_hl(0, "IblScopeChar", { fg = "#BBBB00", nocombine = true })
    vim.api.nvim_set_hl(0, "IblScopeStart", { sp = "#BBBB00", underline = true })
  end)
end

ibl.setup({
  indent = {
    char = "│",
    highlight = {
      "IblIndent1",
      "IblIndent2",
      "IblIndent3",
      "IblIndent4",
      "IblIndent5",
      "IblIndent6",
    },
  },
  whitespace = {
    highlight = {
      "IblIndent1",
      "IblIndent2",
      "IblIndent3",
      "IblIndent4",
      "IblIndent5",
      "IblIndent6",
    },
  },
  scope = {
    enabled = true,
    show_start = true,
    char = "┃",
    highlight = {
      "IblScopeChar",
      "IblScopeStart",
    },
  },
  exclude = {
    filetypes = {
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
    buftypes = {
      "terminal",
      "nofile",
      "quickfix",
      "prompt",
    },
  },
})
