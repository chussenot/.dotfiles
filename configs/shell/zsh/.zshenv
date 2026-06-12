# Zsh Environment Variables
# This file is sourced for ALL zsh invocations (login, non-login, interactive, non-interactive)
# System-wide environment variables that should be available everywhere

############################
# Completion bootstrap guard
############################
# Ubuntu's /etc/zsh/zshrc runs compinit BEFORE ~/.zshrc, with the base fpath.
# That rewrites ~/.zcompdump without our generated completions, which makes
# _completions.zsh delete and fully rebuild the dump on EVERY shell start
# (~1-2.5s). This variable is the escape hatch documented in /etc/zsh/zshrc
# itself; _completions.zsh is the sole compinit owner. Inert on macOS.
# See docs/studies/2026-06-13-zsh-startup-performance.md
# shellcheck disable=SC2034  # consumed by /etc/zsh/zshrc, not this file
skip_global_compinit=1

############################
# Dotfiles location
############################
# Available everywhere, so functions sourced outside an interactive shell
# (e.g. via -c, scripts, IDE tasks) still find the repo root.

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

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
# Guarded so a host-provided locale (e.g. fr_FR.UTF-8) wins over our default.
# Only fall back to en_US.UTF-8 when the environment hasn't set one already.

export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

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

# pdtm (projectdiscovery tool manager)
[[ -d "$HOME/.pdtm/go/bin" ]] && export PATH="$PATH:$HOME/.pdtm/go/bin"

# Note: Mise shims are added automatically by mise activate (in zshrc)
