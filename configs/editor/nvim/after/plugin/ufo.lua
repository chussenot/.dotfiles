-- nvim-ufo Configuration
-- Modern folding with Treesitter (better than default folding)

-- Ensure promise-async is loaded first (required dependency)
local promise_ok = pcall(require, 'promise')
if not promise_ok then
  -- Try alternative name
  promise_ok = pcall(require, 'promise-async')
end

local ok, ufo = pcall(require, 'ufo')
if not ok then
  return
end

-- Configure folding
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using nvim-treesitter as fold provider, nvim-lsp as a fallback
local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if lspconfig_ok then
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }

  -- Update existing LSP clients with folding capabilities
  -- This is handled by the lsp.lua configuration file
end

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return { 'treesitter', 'indent' }
  end,
  open_fold_hl_timeout = 400,
  close_fold_kinds = { 'imports', 'comment' },
  preview = {
    win_config = {
      border = { '', '─', '', '', '', '─', '', '' },
      winhighlight = 'Normal:Folded',
      winblend = 0
    },
    mappings = {
      scrollU = '<C-u>',
      scrollD = '<C-d>',
      jumpTop = '[',
      jumpBot = ']'
    }
  },
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ('  ... %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end
})

-- Key mappings
vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = "Ufo: Open all folds" })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = "Ufo: Close all folds" })
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds, { desc = "Ufo: Open folds except kinds" })
vim.keymap.set('n', 'zm', ufo.closeFoldsWith, { desc = "Ufo: Close folds with" })
vim.keymap.set('n', 'zp', ufo.peekFoldedLinesUnderCursor, { desc = "Ufo: Peek folded lines" })
