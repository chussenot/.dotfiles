-- nvim-notify Configuration
-- Better notification system for Neovim

local ok, notify = pcall(require, 'notify')
if not ok then
  return
end

notify.setup({
  stages = "fade_in_slide_out", -- Animation stages: "fade_in_slide_out", "fade", "slide", "static"
  timeout = 5000, -- Default timeout for notifications
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  on_open = nil,
  on_close = nil,
  render = "default", -- "default", "minimal", "simple", "compact", "wrapped-compact"
  top_down = true, -- Show notifications from top to bottom
})

-- Replace vim.notify with notify
vim.notify = notify

-- Optional: Custom notification styles
-- You can use notify with different log levels:
-- vim.notify("Info message", "info")
-- vim.notify("Warning message", "warn")
-- vim.notify("Error message", "error")
-- vim.notify("Debug message", "debug")

-- Optional: History viewer
-- You can open notification history with: :lua require("notify").history()
