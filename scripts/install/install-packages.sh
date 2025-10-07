#!/bin/bash

# Package installation script
set -e

echo "📦 Installing system packages..."

packages=(
    zsh
    tmux
    python3-pip
    jq
    nasm
    gcc
    gcc-multilib
    libc6-dev
    cmake
    git
    curl
    wget
    unzip
    build-essential
    fzf
)

# Check for ctags
if apt-cache show exuberant-ctags >/dev/null 2>&1; then
    packages+=(exuberant-ctags)
elif apt-cache show universal-ctags >/dev/null 2>&1; then
    packages+=(universal-ctags)
fi

for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "Installing $package..."
        sudo apt-get update
        sudo apt-get install -y "$package"
    else
        echo "$package is already installed"
    fi
done

# Install fzf shell integration if fzf is installed
if command -v fzf >/dev/null 2>&1; then
    echo "🔧 Setting up fzf shell integration..."
    
    # Check if fzf shell integration is already set up
    if [[ ! -f "$HOME/.fzf.zsh" ]]; then
        # Install fzf shell integration
        if [[ -f "$HOME/.fzf/install" ]]; then
            # Use existing fzf installation
            "$HOME/.fzf/install" --all --no-bash --no-fish
        else
            # Install fzf from scratch
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
            "$HOME/.fzf/install" --all --no-bash --no-fish
        fi
        echo "✅ fzf shell integration installed"
    else
        echo "✅ fzf shell integration already configured"
    fi
else
    echo "⚠️  fzf not found, skipping shell integration setup"
fi

echo "✅ Package installation complete!"
