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

echo "✅ Package installation complete!"
