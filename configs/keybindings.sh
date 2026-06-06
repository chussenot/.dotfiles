#!/bin/sh

# Single source of truth for cross-tool keybindings.
#
# Edit a value here, then regenerate the per-tool fragments with:
#
#   ./scripts/setup/generate-keybindings.sh      # or: mise run keybindings
#
# This file is sourced by scripts/setup/generate-keybindings.sh, which
# translates each canonical key into the native syntax for tmux, zsh, and
# Neovim and writes the generated fragments those tools load.
#
# Canonical key notation (translated automatically per tool):
#   C-x     Ctrl + x        -> tmux: C-x   zsh: ^X    nvim: <C-x>
#   M-x     Alt/Meta + x    -> tmux: M-x   zsh: ^[x   nvim: <M-x>
#   Space   the space bar   -> tmux: Space zsh: ' '   nvim: <Space>
#
# Only single-character C-/M- combos and the literal name "Space" are
# understood. Anything else is passed through verbatim — keep additions
# within the notation above so all three tools render correctly.

# These are consumed by sourcing this file from generate-keybindings.sh.
# shellcheck disable=SC2034

# tmux prefix key (default upstream is C-b).
KB_TMUX_PREFIX="C-a"

# tmux bindings table. One binding per line:
#
#   FLAGS:::KEY:::ACTION
#
#   FLAGS  "-" for none, or tmux bind flags: "-n" (no prefix), "-r" (repeat).
#   KEY    canonical key (C-x / M-x / a single char like s or |).
#   ACTION the tmux command, verbatim.
#
# Add a line here, then run: ./scripts/setup/generate-keybindings.sh
# Lines that are blank or start with "#" are ignored. Keep complex bindings
# (popups, menus, command-prompt) in tmux.conf — only simple keys belong here.
KB_TMUX_BINDS='
# Pane navigation (Alt + arrows, no prefix)
-n:::M-Left:::select-pane -L
-n:::M-Right:::select-pane -R
-n:::M-Up:::select-pane -U
-n:::M-Down:::select-pane -D
# Pane resize (vi-style, repeatable)
-r:::J:::resize-pane -D 5
-r:::K:::resize-pane -U 5
-r:::H:::resize-pane -L 5
-r:::L:::resize-pane -R 5
# Zoom toggle
-:::|:::resize-pane -Z
# Splits (s/v, matching vim logic; C- variants kept for muscle memory)
-:::s:::split-window -v -c "#{pane_current_path}"
-:::C-s:::split-window -v -c "#{pane_current_path}"
-:::v:::split-window -h -c "#{pane_current_path}"
-:::C-v:::split-window -h -c "#{pane_current_path}"
'

# Neovim <leader> key.
KB_NVIM_LEADER="Space"

# zsh: kill from the cursor to the beginning of the line (bash-like).
KB_ZSH_KILL_LINE="C-u"
