#!/bin/bash

# Symlink setup script
set -e

echo "🔗 Setting up symlinks..."

DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create parent directory if it doesn't exist
    local parent_dir=$(dirname "$target")
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

create_symlink "$DOTFILES_DIR/configs/shell/zsh/z.sh" "$HOME/z.sh"

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
