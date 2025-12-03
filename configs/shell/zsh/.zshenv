# Zsh Environment Variables
# This file is sourced for ALL zsh invocations (login, non-login, interactive, non-interactive)
# System-wide environment variables that should be available everywhere

############################
# Editor and Pager Settings
############################

export EDITOR="nvim"
export VISUAL="nvim"

# Pager settings
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"

############################
# Language and Locale Settings
############################

export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8

############################
# Timezone
############################

# Timezone (if not already set)
export TZ="${TZ:-$(cat /etc/timezone 2>/dev/null || echo 'UTC')}"

############################
# XDG Base Directory Specification
############################

# XDG Base Directory Specification support
# These should be set early for all shells
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"

############################
# PATH Management
############################
# Centralized PATH configuration for better maintainability
# Order matters: earlier paths take precedence
# Available for all shell invocations (interactive and non-interactive)

# Local user binaries (highest priority)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Cargo/Rust binaries
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Kubectl Krew
[[ -d "${KREW_ROOT:-$HOME/.krew}/bin" ]] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Manual pages
[[ -d "$HOME/.local/share/man" ]] && export MANPATH="$HOME/.local/share/man:$MANPATH"

# Note: Mise shims are added automatically by mise activate (in zshrc)
