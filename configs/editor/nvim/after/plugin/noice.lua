-- noice.nvim Configuration
-- Modern UI for notifications, cmdline, and popups

local ok, noice = pcall(require, 'noice')
if not ok then
  return
end

noice.setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  cmdline = {
    enabled = true, -- enables the Noice cmdline UI
    view = "cmdline_popup", -- view for rendering the cmdline. Change to "cmdline" to get a classic cmdline at the bottom
    opts = {}, -- global options for the cmdline. See section on views
    ---@type table<string, CmdlineFormat>
    format = {
      -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
      -- view: (default is cmdline view)
      -- opts: any options passed to the view
      -- icon_hl_group: optional hl_group for the icon
      -- title: set to false or a string to hide
      cmdline = { pattern = "^:", icon = ":", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = "🔍 ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = "🔍 ", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = "^:%s*lua%s+", icon = "🌙", lang = "lua" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = "💡" },
      input = {}, -- Used by input()
    },
  },
  messages = {
    -- NOTE: If you enable noice messages UI, it will override the default vim.notify
    enabled = true,
    view = "notify", -- default view for messages
    view_error = "notify", -- view for errors
    view_warn = "notify", -- view for warnings
    view_history = "messages", -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  popupmenu = {
    enabled = true, -- enables the Noice popupmenu UI
    ---@type 'nvim'|'cmp'
    backend = "nvim", -- backend to use to show regular cmdline completions
    -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
    kind_icons = {}, -- set to `false` to disable icons
  },
  -- default routes for forward/backward search (default view).
  -- You can add a border to focus/hovered windows by manually adding `border`,
  -- and a `title` set to the window title, e.g.:
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },
  },
  commands = {
    :all = {
      -- options for the message history that you get with `:Noice`
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {},
    },
  },
  notify = {
    -- Noice can be used as a replacement for nvim-notify
    enabled = false, -- we use nvim-notify instead
    view = "notify",
  },
})

-- Key mappings
vim.keymap.set("n", "<S-Enter>", function() noice.redirect(vim.fn.getcmdline()) end, { desc = "Noice: Redirect Cmdline" })
vim.keymap.set("n", "<leader>snl", function() noice.cmd("last") end, { desc = "Noice: Last Message" })
vim.keymap.set("n", "<leader>snh", function() noice.cmd("history") end, { desc = "Noice: History" })
vim.keymap.set("n", "<leader>sna", function() noice.cmd("all") end, { desc = "Noice: All Messages" })
vim.keymap.set("n", "<leader>snd", function() noice.cmd("dismiss") end, { desc = "Noice: Dismiss All" })
vim.keymap.set({ "i", "n", "s" }, "<c-f>", function()
  if not require("noice.lsp").scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true, desc = "Noice: Scroll Forward" })
vim.keymap.set({ "i", "n", "s" }, "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true, desc = "Noice: Scroll Backward" })
