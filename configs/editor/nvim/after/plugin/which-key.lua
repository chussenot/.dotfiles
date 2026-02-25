local icons_ok, mini_icons = pcall(require, 'mini.icons')
if icons_ok then mini_icons.setup() end

local ok, wk = pcall(require, 'which-key')
if not ok then return end

wk.setup()
