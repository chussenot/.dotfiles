-- nvim-cmp Configuration
-- Modern completion engine for Neovim

local ok, cmp = pcall(require, 'cmp')
if not ok then
  return
end

local luasnip_ok, luasnip = pcall(require, 'luasnip')
if not luasnip_ok then
  return
end

-- Load friendly-snippets
local loaders_ok, loaders = pcall(require, 'luasnip.loaders.from_vscode')
if loaders_ok then
  loaders.lazy_load()
end

-- Helper function for super tab behavior
local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    -- Select previous/next item
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),

    -- Accept currently selected item
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Super Tab behavior
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip', priority = 750 },
    { name = 'treesitter', priority = 500 },
  }, {
    { name = 'buffer', priority = 250 },
    { name = 'path', priority = 200 },
    { name = 'spell', priority = 100 },
  }),

  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      local kind_icons = {
        Text = "📝",
        Method = "🔧",
        Function = "🔨",
        Constructor = "🏗",
        Field = "📋",
        Variable = "📊",
        Class = "🏛",
        Interface = "🔌",
        Module = "📦",
        Property = "🏠",
        Unit = "📏",
        Value = "💎",
        Enum = "📑",
        Keyword = "🔑",
        Snippet = "✂️",
        Color = "🎨",
        File = "📄",
        Reference = "🔗",
        Folder = "📁",
        EnumMember = "👥",
        Constant = "⚡",
        Struct = "🏗️",
        Event = "🎯",
        Operator = "⚙️",
        TypeParameter = "🔀",
      }

      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '•', vim_item.kind)

      -- Source name
      vim_item.menu = ({
        nvim_lsp = '[LSP]',
        luasnip = '[Snippet]',
        buffer = '[Buffer]',
        path = '[Path]',
        treesitter = '[TS]',
        spell = '[Spell]',
      })[entry.source.name]

      return vim_item
    end,
  },

  experimental = {
    ghost_text = true, -- Show ghost text for selected completion
  },
})

-- Command line completion
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
