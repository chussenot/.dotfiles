-- diffview.nvim Configuration
-- Better Git diff viewing (complements fugitive)

local ok, diffview = pcall(require, 'diffview')
if not ok then
  return
end

diffview.setup({
  diff_binaries = false, -- Show diffs for binaries
  enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
  git_cmd = { "git" }, -- The git executable to use
  use_icons = true, -- Requires nvim-web-devicons
  show_help_hints = true, -- Show hints for how to use the view
  watch_index = true, -- Update views and index buffers when the git index changes.
  icons = { -- Only applies when use_icons is true.
    folder_closed = "📁",
    folder_open = "📂",
  },
  signs = {
    fold_closed = "▶",
    fold_open = "▼",
    done = "✓",
  },
  view = {
    -- Configure the layout and behavior of different types of views.
    -- Available layouts:
    --  'diff1_plain'
    --    |'diff2_horizontal'
    --    |'diff2_vertical'
    --    |'diff3_horizontal'
    --    |'diff3_vertical'
    --    |'diff4_horizontal'
    --  For more info, see ':h diffview-config-view.x.layout'.
    default = {
      -- Config for changed files, and staged files in diff views.
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
    merge_tool = {
      -- Config for conflicted files in diff views during a merge or rebase.
      layout = "diff3_horizontal",
      disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
      winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
    },
    file_history = {
      -- Config for file history views.
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
  },
  file_panel = {
    listing_style = "tree", -- One of 'list' or 'tree'
    tree_options = { -- Only applies when listing_style is 'tree'
      flatten_dirs = true, -- Flatten dirs that only contain one single dir
      folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
    },
    win_config = { -- See ':h diffview-config-win_config'
      position = "left",
      width = 35,
      win_opts = {}
    },
  },
  file_history_panel = {
    log_options = { -- See ':h diffview-config-log_options'
      git = {
        single_file = {
          diff_merges = "combined",
        },
        multi_file = {
          diff_merges = "first-parent",
        },
      },
    },
    win_config = { -- See ':h diffview-config-win_config'
      position = "bottom",
      height = 16,
      win_opts = {}
    },
  },
  commit_log_panel = {
    win_config = { -- See ':h diffview-config-win_config'
      win_opts = {},
    }
  },
  default_args = { -- Default args prepended to the arg-list for the listed commands
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {}, -- See ':h diffview-config-hooks'
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      ["<tab>"] = diffview.actions.select_next_entry, -- Open the diff for the next file
      ["<s-tab>"] = diffview.actions.select_prev_entry, -- Open the diff for the previous file
      ["gf"] = diffview.actions.goto_file, -- Open the file in the previous tabpage
      ["<C-w><C-f>"] = diffview.actions.goto_file_split, -- Open the file in a new split
      ["<C-w>gf"] = diffview.actions.goto_file_tab, -- Open the file in a new tabpage
      ["<leader>e"] = diffview.actions.focus_files, -- Bring focus to the files panel
      ["<leader>b"] = diffview.actions.toggle_files, -- Toggle the files panel.
      ["g<C-x>"] = diffview.actions.cycle_layout, -- Cycle through available layouts
      ["[x"] = diffview.actions.prev_conflict, -- In the merge_tool: jump to the previous conflict
      ["]x"] = diffview.actions.next_conflict, -- In the merge_tool: jump to the next conflict
      ["<leader>co"] = diffview.actions.conflict_choose("ours"), -- Choose the OURS version of a conflict
      ["<leader>ct"] = diffview.actions.conflict_choose("theirs"), -- Choose the THEIRS version of a conflict
      ["<leader>cb"] = diffview.actions.conflict_choose("base"), -- Choose the BASE version of a conflict
      ["<leader>ca"] = diffview.actions.conflict_choose("all"), -- Choose all the versions of a conflict
      ["dx"] = diffview.actions.conflict_choose("none"), -- Delete the conflict region
    },
    diff1 = { -- Mappings in single window diff layouts
      ["g<tab>"] = diffview.actions.select_next_entry,
      ["g<S-tab>"] = diffview.actions.select_prev_entry,
    },
    diff2 = { -- Mappings in 2-way diff layouts
      ["g<tab>"] = diffview.actions.select_next_entry,
      ["g<S-tab>"] = diffview.actions.select_prev_entry,
    },
    diff3 = {
      -- Mappings in 3-way diff layouts
      [{ "g<tab>", "i", "x" }] = diffview.actions.select_next_entry,
      [{ "g<S-tab>", "i", "x" }] = diffview.actions.select_prev_entry,
    },
    diff4 = {
      -- Mappings in 4-way diff layouts
      [{ "g<tab>", "i", "x" }] = diffview.actions.select_next_entry,
      [{ "g<S-tab>", "i", "x" }] = diffview.actions.select_prev_entry,
    },
    file_panel = {
      ["j"] = diffview.actions.next_entry, -- Bring the cursor to the next file entry
      ["<down>"] = diffview.actions.next_entry,
      ["k"] = diffview.actions.prev_entry, -- Bring the cursor to the previous file entry.
      ["<up>"] = diffview.actions.prev_entry,
      ["<cr>"] = diffview.actions.select_entry, -- Open the diff for the selected entry.
      ["o"] = diffview.actions.select_entry,
      ["<2-LeftMouse>"] = diffview.actions.select_entry,
      ["-"] = diffview.actions.toggle_stage_entry, -- Stage / unstage the selected entry.
      ["S"] = diffview.actions.stage_all, -- Stage all entries.
      ["U"] = diffview.actions.unstage_all, -- Unstage all entries.
      ["X"] = diffview.actions.restore_entry, -- Restore entry to the state on the left side.
      ["L"] = diffview.actions.open_commit_log, -- Open the commit log panel.
      ["<c-b>"] = diffview.actions.scroll_view(-0.25), -- Scroll the view up
      ["<c-f>"] = diffview.actions.scroll_view(0.25), -- Scroll the view down
      ["<tab>"] = diffview.actions.select_next_entry,
      ["<s-tab>"] = diffview.actions.select_prev_entry,
      ["gf"] = diffview.actions.goto_file,
      ["<C-w><C-f>"] = diffview.actions.goto_file_split,
      ["<C-w>gf"] = diffview.actions.goto_file_tab,
      ["i"] = diffview.actions.listing_style, -- Toggle between 'list' and 'tree' views
      ["f"] = diffview.actions.toggle_flatten_dirs, -- Flatten empty subdirectories in tree listing style.
      ["R"] = diffview.actions.refresh_files, -- Update stats of the files in the list
      ["<leader>e"] = diffview.actions.focus_files,
      ["<leader>b"] = diffview.actions.toggle_files,
      ["g<C-x>"] = diffview.actions.cycle_layout,
      ["[x"] = diffview.actions.prev_conflict,
      ["]x"] = diffview.actions.next_conflict,
      ["<leader>co"] = diffview.actions.conflict_choose("ours"),
      ["<leader>ct"] = diffview.actions.conflict_choose("theirs"),
      ["<leader>cb"] = diffview.actions.conflict_choose("base"),
      ["<leader>ca"] = diffview.actions.conflict_choose("all"),
      ["dx"] = diffview.actions.conflict_choose("none"),
    },
    file_history_panel = {
      ["g!"] = diffview.actions.options, -- Open the option panel
      ["<C-A-d>"] = diffview.actions.open_in_diffview, -- Open the entry under the cursor in a diffview
      ["y"] = diffview.actions.copy_hash, -- Copy the commit hash of the entry under the cursor
      ["L"] = diffview.actions.open_commit_log,
      ["zR"] = diffview.actions.open_all_folds,
      ["zM"] = diffview.actions.close_all_folds,
      ["j"] = diffview.actions.next_entry,
      ["<down>"] = diffview.actions.next_entry,
      ["k"] = diffview.actions.prev_entry,
      ["<up>"] = diffview.actions.prev_entry,
      ["<cr>"] = diffview.actions.select_entry,
      ["o"] = diffview.actions.select_entry,
      ["<2-LeftMouse>"] = diffview.actions.select_entry,
      ["<c-b>"] = diffview.actions.scroll_view(-0.25),
      ["<c-f>"] = diffview.actions.scroll_view(0.25),
      ["<tab>"] = diffview.actions.select_next_entry,
      ["<s-tab>"] = diffview.actions.select_prev_entry,
      ["gf"] = diffview.actions.goto_file,
      ["<C-w><C-f>"] = diffview.actions.goto_file_split,
      ["<C-w>gf"] = diffview.actions.goto_file_tab,
      ["<leader>e"] = diffview.actions.focus_files,
      ["<leader>b"] = diffview.actions.toggle_files,
      ["g<C-x>"] = diffview.actions.cycle_layout,
    },
    option_panel = {
      ["<tab>"] = diffview.actions.select_entry,
      ["q"] = diffview.actions.close,
    },
  },
})

-- Key mappings
vim.keymap.set("n", "<leader>gd", function() diffview.open() end, { desc = "Diffview: Open diff" })
vim.keymap.set("n", "<leader>gD", function() diffview.open("HEAD~1") end, { desc = "Diffview: Open diff HEAD~1" })
vim.keymap.set("n", "<leader>gh", function() diffview.file_history() end, { desc = "Diffview: File history" })
vim.keymap.set("n", "<leader>gq", function() diffview.close() end, { desc = "Diffview: Close" })
