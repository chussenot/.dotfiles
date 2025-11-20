#!/bin/bash

# Backup script for dotfiles
set -e

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Creating backup in $BACKUP_DIR"

# Backup existing dotfiles
files_to_backup=(
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.inputrc"
    "$HOME/.config/nvim"
    "$HOME/.tool-versions"

for file in "${files_to_backup[@]}"; do
    if [ -e "$file" ]; then
        cp -r "$file" "$BACKUP_DIR/"
        echo "✅ Backed up $file"
    fi
done

echo "✅ Backup complete!"
