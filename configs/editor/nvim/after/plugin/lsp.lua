-- LSP Configuration
-- Modern LSP setup using nvim-lspconfig and mason

local ok, lspconfig = pcall(require, 'lspconfig')
if not ok then
  return
end

local mason_ok, mason = pcall(require, 'mason')
if not mason_ok then
  return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_ok then
  return
end

-- Setup Mason (LSP installer)
mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Configure Mason to automatically install LSP servers
mason_lspconfig.setup({
  ensure_installed = {
    -- Add your preferred language servers here
    -- Examples:
    -- 'lua_ls',      -- Lua
    -- 'ruby_ls',     -- Ruby (Solargraph)
    -- 'pyright',     -- Python
    -- 'rust_analyzer', -- Rust
    -- 'tsserver',    -- TypeScript/JavaScript
    -- 'gopls',       -- Go
    -- 'elixirls',    -- Elixir
    -- 'bashls',      -- Bash
    -- 'yamlls',      -- YAML
    -- 'jsonls',      -- JSON
    -- 'html',        -- HTML
    -- 'cssls',       -- CSS
  },
  automatic_installation = false, -- Set to true for auto-install
})

-- Key mappings for LSP
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- Go to definition
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Common LSP capabilities
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if cmp_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

-- Language server configurations
-- Uncomment and configure the ones you need

-- Lua
-- lspconfig.lua_ls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     Lua = {
--       runtime = { version = 'LuaJIT' },
--       diagnostics = { globals = { 'vim' } },
--       workspace = { library = vim.api.nvim_get_runtime_file("", true) },
--       telemetry = { enable = false },
--     },
--   },
-- }

-- Ruby (Solargraph)
-- lspconfig.solargraph.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- Python (Pyright)
-- lspconfig.pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- Rust
-- lspconfig.rust_analyzer.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- TypeScript/JavaScript
-- lspconfig.tsserver.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- Go
-- lspconfig.gopls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- Elixir
-- lspconfig.elixirls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   cmd = { "elixir-ls" },
-- }

-- Bash
-- lspconfig.bashls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- YAML
-- lspconfig.yamlls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- JSON
-- lspconfig.jsonls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- HTML
-- lspconfig.html.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- CSS
-- lspconfig.cssls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- Diagnostics configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Diagnostic signs
local signs = { Error = "✗", Warn = "⚠", Hint = "➤", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
