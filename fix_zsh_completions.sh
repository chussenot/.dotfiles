#!/bin/zsh

# Clean up broken completions
echo "Cleaning up broken completions..."
rm -f ~/snap/code/191/.local/share/zinit/completions/_*

# Reinstall zinit if needed
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    echo "Reinstalling zinit..."
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi

# Rebuild completion cache
echo "Rebuilding completion cache..."
rm -f ~/.zcompdump*
autoload -Uz compinit
compinit

echo "Zsh completion fixes applied. Please restart your shell." 