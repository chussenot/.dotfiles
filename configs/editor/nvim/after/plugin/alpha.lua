-- alpha-nvim Configuration
-- Startup dashboard

local ok, alpha = pcall(require, 'alpha')
if not ok then
  return
end

local dashboard = require('alpha.themes.dashboard')

-- Animated Header Frames
local header_frames = {
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      C H U S S E N O T                             ",
    "                                                     ",
  },
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      █ C H U S S E N O T █                          ",
    "                                                     ",
  },
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      ██ C H U S S E N O T ██                        ",
    "                                                     ",
  },
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      ███ C H U S S E N O T ███                      ",
    "                                                     ",
  },
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      ██ C H U S S E N O T ██                        ",
    "                                                     ",
  },
  {
    "                                                     ",
    "  ╔═╗╦ ╦╔═╗╔═╗╔═╗╔═╗╔═╗╔═╗ ╔╦╗                     ",
    "  ║  ╠═╣║╣ ║ ╦║ ║║ ║║ ║║╣   ║                      ",
    "  ╚═╝╩ ╩╚═╝╚═╝╚═╝╚═╝╚═╝╚═╝ ╩ ╩                     ",
    "                                                     ",
    "      █ C H U S S E N O T █                          ",
    "                                                     ",
  },
}

-- Animation state
local current_frame = 1
local animation_timer = nil

-- Function to update header animation
local function animate_header()
  -- Check if we're on the alpha buffer
  local buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "alpha" then
    return
  end

  -- Update to next frame
  current_frame = (current_frame % #header_frames) + 1
  dashboard.section.header.val = header_frames[current_frame]

  -- Get current buffer lines
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #lines == 0 then
    return
  end

  -- Find header section (first few lines)
  local header_lines = #header_frames[1]

  -- Update header lines in buffer
  vim.api.nvim_buf_set_lines(buf, 0, header_lines, false, header_frames[current_frame])

  -- Redraw to show changes
  vim.cmd("redraw")
end

-- Start animation timer
local function start_animation()
  if animation_timer then
    animation_timer:stop()
    animation_timer:close()
  end

  animation_timer = vim.loop.new_timer()
  animation_timer:start(0, 500, vim.schedule_wrap(animate_header))
end

-- Stop animation timer
local function stop_animation()
  if animation_timer then
    animation_timer:stop()
    animation_timer:close()
    animation_timer = nil
  end
end

-- Initialize with first frame
dashboard.section.header.val = header_frames[1]

-- Buttons
dashboard.section.buttons.val = {
  dashboard.button("e", "📁  New file", ":ene <BAR> startinsert<CR>"),
  dashboard.button("f", "🔍  Find file", ":Telescope find_files<CR>"),
  dashboard.button("r", "📂  Recent files", ":Telescope oldfiles<CR>"),
  dashboard.button("g", "🔎  Live grep", ":Telescope live_grep<CR>"),
  dashboard.button("c", "⚙️  Configuration", ":e $MYVIMRC<CR>"),
  -- dashboard.button("s", "💾  Restore Session", [[:lua require("persistence").load()<cr>]]),
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

-- Disable statusline and tabline on alpha buffer and start animation
vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  desc = "disable status and tabline for alpha, start animation",
  callback = function()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
    -- Start animation when dashboard is ready
    start_animation()
    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      desc = "enable status and tabline after alpha, stop animation",
      callback = function()
        vim.opt.laststatus = 2
        vim.opt.showtabline = 2
        -- Stop animation when leaving dashboard
        stop_animation()
      end,
    })
  end,
})

-- Keybinding to open dashboard
vim.keymap.set("n", "<leader>d", "<cmd>Alpha<cr>", { desc = "Open dashboard" })
