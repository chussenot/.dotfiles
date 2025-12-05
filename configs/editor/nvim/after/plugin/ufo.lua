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

-- Note: LSP folding capabilities are configured in lsp.lua

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    -- Validate buffer before using treesitter to avoid E475 errors
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      return { 'treesitter', 'indent' }
    else
      -- Fallback to indent-only if buffer is invalid
      return { 'indent' }
    end
  end,
  open_fold_hl_timeout = 400,
  -- Use new API: close_fold_kinds_for_ft instead of deprecated close_fold_kinds
  close_fold_kinds_for_ft = {
    default = { 'imports', 'comment' },
  },
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
