-- nvim-autopairs Configuration
-- Modern autopairs plugin with Treesitter and LSP integration

local ok, npairs = pcall(require, 'nvim-autopairs')
if not ok then
  return
end
local Rule = require('nvim-autopairs.rule')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

npairs.setup({
  check_ts = true, -- Use Treesitter
  ts_config = {
    lua = { 'string', 'source' },
    javascript = { 'string', 'template_string' },
    java = false,
  },
  disable_filetype = { 'TelescopePrompt', 'vim' },
  fast_wrap = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'PmenuSel',
    highlight_grey = 'LineNr'
  },
})

-- Integrate with nvim-cmp
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

-- Add rules for specific cases
npairs.add_rules({
  Rule(' ', ' ')
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end)
    :with_move(function(opts)
      return opts.prev_char:match('.%)') ~= nil
    end)
    :use_key('<C-g>'),
  Rule('%(.*%)%s*%=>$', ' {  }', { 'typescript', 'typescriptreact', 'javascript' })
    :use_regex(true)
    :set_end_pair_length(2),
  -- French quotation marks « »
  Rule('«', '»', { 'markdown', 'text', 'tex' })
    :with_pair(function() return false end)
    :with_move(function(opts)
      return opts.prev_char:match('.»') ~= nil
    end)
    :use_key('»'),
})
