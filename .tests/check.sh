#!/bin/sh

# Validation script for dotfiles installation
# POSIX-compliant version
# This script verifies that the installation completed successfully

set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

_print_success() {
    printf '%b[PASS]%b %s\n' "${GREEN}" "${NC}" "$1"
}

_print_error() {
    printf '%b[FAIL]%b %s\n' "${RED}" "${NC}" "$1"
}

_print_info() {
    printf '%b[INFO]%b %s\n' "${YELLOW}" "${NC}" "$1"
}

_errors=0

# Check if a file or directory exists
_check_exists() {
    _path="$1"
    _description="$2"
    if [ -e "${_path}" ]; then
        _print_success "${_description}: ${_path}"
        return 0
    else
        _print_error "${_description}: ${_path} (not found)"
        _errors=$((_errors + 1))
        return 1
    fi
}

# Check if a command is available in PATH
_check_command() {
    _cmd="$1"
    if command -v "${_cmd}" >/dev/null 2>&1; then
        _cmd_path=$(command -v "${_cmd}")
        _print_success "Command ${_cmd} found at ${_cmd_path}"
        return 0
    else
        _print_error "Command ${_cmd} not found in PATH"
        _errors=$((_errors + 1))
        return 1
    fi
}

_print_info "Starting dotfiles installation validation..."
printf '\n'

# Check expected files and directories
_print_info "Checking expected files and directories..."

_check_exists "${HOME}/.zshrc" "Zsh configuration"
_check_exists "${HOME}/.tmux.conf" "Tmux configuration"
_check_exists "${HOME}/.inputrc" "Input configuration"
_check_exists "${HOME}/.config/nvim" "Neovim configuration directory"
# Check for nvim config (init.vim or init.lua)
if [ -f "${HOME}/.config/nvim/init.vim" ] || [ -f "${HOME}/.config/nvim/init.lua" ]; then
    _print_success "Neovim init file exists"
else
    _print_error "Neovim init file not found (init.vim or init.lua)"
    _errors=$((_errors + 1))
fi
_check_exists "${HOME}/.zsh" "Zsh directory"
_check_exists "${HOME}/.zsh/aliases.zsh" "Zsh aliases"
_check_exists "${HOME}/.zsh/functions.zsh" "Zsh functions"
_check_exists "${HOME}/.zsh/_completions.zsh" "Zsh completions"
_check_exists "${HOME}/.dotfiles" "Dotfiles repository"

# Check for Oh My Zsh
if [ -d "${HOME}/.oh-my-zsh" ]; then
    _print_success "Oh My Zsh installed"
else
    _print_error "Oh My Zsh not found"
    _errors=$((_errors + 1))
fi

# Check for Zinit
if [ -d "${HOME}/.local/share/zinit/zinit.git" ]; then
    _print_success "Zinit Plugin Manager installed"
else
    _print_error "Zinit Plugin Manager not found"
    _errors=$((_errors + 1))
fi

# Check for mise installation
if [ -d "${HOME}/.local/bin" ]; then
    _print_success "Local bin directory exists"
    if [ -f "${HOME}/.local/bin/mise" ]; then
        _print_success "mise binary found"
    else
        _print_info "mise binary not found (may be installing)"
    fi
else
    _print_error "Local bin directory not found"
    _errors=$((_errors + 1))
fi

printf '\n'

# Check expected commands
_print_info "Checking expected commands..."

# Essential commands that should be available
_check_command "zsh"
_check_command "git"
_check_command "curl"

# Check if mise is available (may be in PATH or need to be sourced)
if command -v mise >/dev/null 2>&1; then
    _print_success "mise command found"
elif [ -f "${HOME}/.local/bin/mise" ]; then
    _print_success "mise binary found at ${HOME}/.local/bin/mise"
else
    _print_error "mise not found"
    _errors=$((_errors + 1))
fi

# Check if nvim is available (may not be installed in minimal test)
# This is optional - nvim plugins installation might fail, but that's okay
if command -v nvim >/dev/null 2>&1; then
    _print_success "nvim command found"
else
    _print_info "nvim not found (optional - may not be installed in test environment)"
fi

printf '\n'

# Check symlinks are correct
_print_info "Checking symlinks..."

_check_symlink() {
    _target="$1"
    _source="$2"
    _description="$3"
    if [ -L "${_target}" ]; then
        _link_target=$(readlink "${_target}" 2>/dev/null || printf '')
        if [ "${_link_target}" = "${_source}" ]; then
            _print_success "${_description}: ${_target} -> ${_source}"
            return 0
        else
            _print_error "${_description}: ${_target} points to ${_link_target}, expected ${_source}"
            _errors=$((_errors + 1))
            return 1
        fi
    else
        _print_error "${_description}: ${_target} is not a symlink"
        _errors=$((_errors + 1))
        return 1
    fi
}

if [ -L "${HOME}/.zshrc" ]; then
    _check_symlink "${HOME}/.zshrc" "${HOME}/.dotfiles/configs/shell/zsh/zshrc" "Zshrc symlink"
fi

if [ -L "${HOME}/.tmux.conf" ]; then
    _check_symlink "${HOME}/.tmux.conf" "${HOME}/.dotfiles/configs/terminal/tmux/tmux.conf" "Tmux config symlink"
fi

printf '\n'

# Summary
if [ "${_errors}" -eq 0 ]; then
    _print_success "All validation checks passed!"
    exit 0
else
    _print_error "Validation failed with ${_errors} error(s)"
    exit 1
fi
