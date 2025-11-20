#!/usr/bin/env bash

# Symlink setup script
set -euo pipefail
IFS=$'\n\t'

echo "🔗 Setting up symlinks..."

DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    # Create parent directory if it doesn't exist
    local parent_dir
    parent_dir=$(dirname "$target")
    if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
    fi

    if [ -L "$target" ]; then
        rm -f "$target"
    elif [ -f "$target" ] || [ -d "$target" ]; then
        mv "$target" "$target.backup"
    fi

    ln -sf "$source" "$target"
    echo "✅ Linked $target"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/configs/terminal/tmux/tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/configs/shell/inputrc" "$HOME/.inputrc"
# Create nvim config directory and symlink
mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/configs/editor/nvim" "$HOME/.config/nvim"

# Create ~/.vim symlink for backward compatibility with existing vim config
create_symlink "$DOTFILES_DIR/configs/editor/nvim" "$HOME/.vim"

# Create mise config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/mise/config.toml" ]; then
    mkdir -p "$HOME/.config/mise"
    create_symlink "$DOTFILES_DIR/configs/tools/mise/config.toml" "$HOME/.config/mise/config.toml"
fi

# Create tool-versions symlink if it exists
if [ -f "$DOTFILES_DIR/configs/tools/mise/tool-versions" ]; then
    create_symlink "$DOTFILES_DIR/configs/tools/mise/tool-versions" "$HOME/.tool-versions"
fi

# Create atuin config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/atuin/config.toml" ]; then
    mkdir -p "$HOME/.config/atuin"
    create_symlink "$DOTFILES_DIR/configs/tools/atuin/config.toml" "$HOME/.config/atuin/config.toml"
fi

# Create yazi config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/yazi/yazi.toml" ]; then
    mkdir -p "$HOME/.config/yazi"
    create_symlink "$DOTFILES_DIR/configs/tools/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
fi

# Create gitignore_global if it exists
if [ -f "$DOTFILES_DIR/configs/git/.gitignore_global" ]; then
    create_symlink "$DOTFILES_DIR/configs/git/.gitignore_global" "$HOME/.gitignore_global"
fi

# Create GitHub CLI config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/gh/config.yml" ]; then
    mkdir -p "$HOME/.config/gh"
    create_symlink "$DOTFILES_DIR/configs/tools/gh/config.yml" "$HOME/.config/gh/config.yml"
fi

# Create k9s config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/k9s/config.yaml" ]; then
    mkdir -p "$HOME/.config/k9s"
    create_symlink "$DOTFILES_DIR/configs/tools/k9s/config.yaml" "$HOME/.config/k9s/config.yaml"
fi

# Create htop config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/htop/htoprc" ]; then
    mkdir -p "$HOME/.config/htop"
    create_symlink "$DOTFILES_DIR/configs/tools/htop/htoprc" "$HOME/.config/htop/htoprc"
fi

# Create glow config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/glow/glow.yml" ]; then
    mkdir -p "$HOME/.config/glow"
    create_symlink "$DOTFILES_DIR/configs/tools/glow/glow.yml" "$HOME/.config/glow/glow.yml"
fi

# Create bat config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/bat/config" ]; then
    mkdir -p "$HOME/.config/bat"
    create_symlink "$DOTFILES_DIR/configs/tools/bat/config" "$HOME/.config/bat/config"
fi

# Create tig config if it exists
if [ -f "$DOTFILES_DIR/configs/tools/tig/tigrc" ]; then
    create_symlink "$DOTFILES_DIR/configs/tools/tig/tigrc" "$HOME/.tigrc"
fi

# Create zsh directory and symlink aliases and functions
mkdir -p "$HOME/.zsh"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/aliases.zsh" "$HOME/.zsh/aliases.zsh"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/functions.zsh" "$HOME/.zsh/functions.zsh"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/_completions.zsh" "$HOME/.zsh/_completions.zsh"

mkdir -p ~/.zsh/completions

# Create local directories if they don't exist
mkdir -p "$HOME/.local/share/zsh"
mkdir -p "$HOME/.local/share/nvim"
mkdir -p "$HOME/.config"

echo "✅ Symlink setup complete!"
