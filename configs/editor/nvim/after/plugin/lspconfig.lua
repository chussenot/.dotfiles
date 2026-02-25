local ok, lspconfig = pcall(require, 'lspconfig')
if not ok then return end

-- Build capabilities with nvim-cmp if available
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Ruby (solargraph)
if vim.fn.executable('solargraph') == 1 then
  lspconfig.solargraph.setup({
    capabilities = capabilities,
  })
end

-- Lua
if vim.fn.executable('lua-language-server') == 1 then
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      },
    },
  })
end

-- Fallback keymaps for NeoVim < 0.11 (0.11+ provides defaults)
if vim.fn.has('nvim-0.11') == 0 then
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local buf = args.buf
      local opts = { buffer = buf, silent = true }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)
    end,
  })
end
