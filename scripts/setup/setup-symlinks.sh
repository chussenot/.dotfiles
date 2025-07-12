#!/bin/bash

# Symlink setup script
set -e

echo "🔗 Setting up symlinks..."

DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        mv "$target" "$target.backup"
    fi
    
    ln -s "$source" "$target"
    echo "✅ Linked $target"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/configs/terminal/tmux/tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/configs/editor/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/configs/tools/mise/config.toml" "$HOME/.config/mise/config.toml"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/z.sh" "$HOME/z.sh"

# Create local directories if they don't exist
mkdir -p "$HOME/.local/share/zsh"
mkdir -p "$HOME/.local/share/nvim"

echo "✅ Symlink setup complete!"
