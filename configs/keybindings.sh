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

# Neovim <leader> key.
KB_NVIM_LEADER="Space"

# zsh: kill from the cursor to the beginning of the line (bash-like).
KB_ZSH_KILL_LINE="C-u"
