#!/bin/sh

# Package installation script
# POSIX-compliant version

set -eu

printf '📦 Installing system packages...\n'

# POSIX-compliant package list (using positional parameters)
# We'll iterate through packages one by one
_packages="zsh tmux python3-pip jq nasm gcc gcc-multilib libc6-dev cmake git curl wget unzip build-essential fzf bat htop net-tools tree ripgrep fd-find"

# Check for ctags and add to list if available
if apt-cache show exuberant-ctags >/dev/null 2>&1; then
    _packages="${_packages} exuberant-ctags"
elif apt-cache show universal-ctags >/dev/null 2>&1; then
    _packages="${_packages} universal-ctags"
fi

# Install packages
for _package in ${_packages}; do
    if ! dpkg -s "${_package}" >/dev/null 2>&1; then
        printf 'Installing %s...\n' "${_package}"
        sudo apt-get update
        sudo apt-get install -y "${_package}"
    else
        printf '%s is already installed\n' "${_package}"
    fi
done

# Install fzf shell integration if fzf is installed
if command -v fzf >/dev/null 2>&1; then
    printf '🔧 Setting up fzf shell integration...\n'

    # Check if fzf shell integration is already set up
    if [ ! -f "${HOME}/.fzf.zsh" ]; then
        # Install fzf shell integration
        if [ -f "${HOME}/.fzf/install" ]; then
            # Use existing fzf installation
            "${HOME}/.fzf/install" --all --no-bash --no-fish
        else
            # Install fzf from scratch
            if command -v git >/dev/null 2>&1; then
                git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
                "${HOME}/.fzf/install" --all --no-bash --no-fish
            else
                printf '⚠️  git not found, cannot install fzf\n'
            fi
        fi
        printf '✅ fzf shell integration installed\n'
    else
        printf '✅ fzf shell integration already configured\n'
    fi
else
    printf '⚠️  fzf not found, skipping shell integration setup\n'
fi

printf '✅ Package installation complete!\n'
