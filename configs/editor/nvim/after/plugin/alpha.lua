-- alpha-nvim Configuration
-- Startup dashboard

local ok, alpha = pcall(require, 'alpha')
if not ok then
  return
end

local dashboard = require('alpha.themes.dashboard')

-- Header
dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
  "                                                     ",
}

-- Buttons
dashboard.section.buttons.val = {
  dashboard.button("e", "📁  New file", ":ene <BAR> startinsert<CR>"),
  dashboard.button("f", "🔍  Find file", ":Telescope find_files<CR>"),
  dashboard.button("r", "📂  Recent files", ":Telescope oldfiles<CR>"),
  dashboard.button("g", "🔎  Live grep", ":Telescope live_grep<CR>"),
  dashboard.button("c", "⚙️  Configuration", ":e $MYVIMRC<CR>"),
  dashboard.button("s", "💾  Restore Session", [[:lua require("persistence").load()<cr>]]),
  dashboard.button("q", "❌  Quit", ":qa<CR>"),
}

-- Footer
local function footer()
  local datetime = os.date("  %d-%m-%Y  %H:%M:%S")
  local version = vim.version()
  local nvim_version = "  v" .. version.major .. "." .. version.minor .. "." .. version.patch
  return datetime .. " · " .. nvim_version
end

dashboard.section.footer.val = footer()

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true

alpha.setup(dashboard.opts)

-- Disable statusline and tabline on alpha buffer
vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  desc = "disable status and tabline for alpha",
  callback = function()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      desc = "enable status and tabline after alpha",
      callback = function()
        vim.opt.laststatus = 2
        vim.opt.showtabline = 2
      end,
    })
  end,
})
