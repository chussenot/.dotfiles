-- LSP Configuration
-- Modern LSP setup using Neovim 0.11+ vim.lsp.config API
-- Migrated from deprecated lspconfig framework

local mason_ok, mason = pcall(require, 'mason')
if not mason_ok then
  return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lspconfig_ok then
  return
end

-- Check if we're on Neovim 0.11+ with new LSP API
-- The new API doesn't require explicitly requiring 'lspconfig'
-- Only use legacy API as fallback for older Neovim versions
local use_legacy_api = not vim.lsp.config
local legacy_lspconfig = nil

if use_legacy_api then
  -- Fallback to old API for older Neovim versions
  local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
  if not lspconfig_ok then
    vim.notify("LSP: Could not load lspconfig. Please upgrade to Neovim 0.11+ or install nvim-lspconfig", vim.log.levels.WARN)
    return
  end
  legacy_lspconfig = lspconfig
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
    -- Core languages
    'lua_ls',        -- Lua
    'gopls',         -- Go
    'pyright',       -- Python
    'rust_analyzer', -- Rust
    'ts_ls',         -- TypeScript/JavaScript
    'solargraph',    -- Ruby
    -- Data formats
    'yamlls',        -- YAML
    'jsonls',        -- JSON
    'taplo',         -- TOML
  },
  automatic_installation = true, -- Auto-install missing servers
})

-- Key mappings for LSP
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr, desc = 'LSP' }

  -- Go to definition
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to declaration' }))
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to definition' }))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', bufopts, { desc = 'LSP: Hover' }))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to implementation' }))
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend('force', bufopts, { desc = 'LSP: Signature help' }))
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', bufopts, { desc = 'LSP: Add workspace folder' }))
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', bufopts, { desc = 'LSP: Remove workspace folder' }))
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend('force', bufopts, { desc = 'LSP: List workspace folders' }))
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, vim.tbl_extend('force', bufopts, { desc = 'LSP: Type definition' }))
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, vim.tbl_extend('force', bufopts, { desc = 'LSP: Rename' }))
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', bufopts, { desc = 'LSP: Code action' }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', bufopts, { desc = 'LSP: References' }))
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, vim.tbl_extend('force', bufopts, { desc = 'LSP: Format' }))
end

-- Common LSP capabilities
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if cmp_lsp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Common configuration for all LSP servers
local common_config = {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Language server configurations using vim.lsp.config API (Neovim 0.11+)

-- Helper function to configure LSP servers
local function setup_lsp(name, config)
  if not use_legacy_api then
    -- Neovim 0.11+ API: vim.lsp.config(name, config)
    local merged_config = vim.tbl_deep_extend('force', common_config, config or {})
    vim.lsp.config(name, merged_config)
    vim.lsp.enable(name)
  else
    -- Fallback for older Neovim versions
    if legacy_lspconfig and legacy_lspconfig[name] then
      legacy_lspconfig[name].setup(vim.tbl_deep_extend('force', common_config, config or {}))
    end
  end
end

-- Lua
setup_lsp('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})

-- Go
setup_lsp('gopls', {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

-- Python (Pyright)
setup_lsp('pyright', {
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        typeCheckingMode = "basic",
      },
    },
  },
})

-- Rust
setup_lsp('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})

-- TypeScript/JavaScript (covers both JS and TS)
setup_lsp('ts_ls', {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})

-- Ruby (Solargraph)
setup_lsp('solargraph', {
  settings = {
    solargraph = {
      diagnostics = true,
      formatting = true,
    },
  },
})

-- YAML
setup_lsp('yamlls', {
  settings = {
    yaml = {
      schemas = {
        kubernetes = "*.yaml",
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
        ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
        ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
        ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
        ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
        ["https://json.schemastore.org/dependabot-2.0"] = ".github/dependabot.{yml,yaml}",
        ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
        ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/3.1/schema.json"] = "*api*.{yml,yaml}",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
        ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
      },
    },
  },
})

-- JSON
local json_schemas = {}
local schemastore_ok, schemastore = pcall(require, 'schemastore')
if schemastore_ok then
  json_schemas = schemastore.json.schemas()
end

setup_lsp('jsonls', {
  settings = {
    json = {
      schemas = json_schemas,
      validate = { enable = true },
    },
  },
})

-- TOML
setup_lsp('taplo', {})

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
