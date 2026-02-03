#!/bin/sh

# Symlink setup script
# POSIX-compliant version

set -eu

printf '🔗 Setting up symlinks...\n'

DOTFILES_DIR="${HOME}/.dotfiles"

# Function to create symlink
create_symlink() {
    _source="$1"
    _target="$2"

    # Create parent directory if it doesn't exist
    _parent_dir=$(dirname "${_target}")
    if [ ! -d "${_parent_dir}" ]; then
        mkdir -p "${_parent_dir}"
    fi

    if [ -L "${_target}" ]; then
        rm -f "${_target}"
    elif [ -f "${_target}" ] || [ -d "${_target}" ]; then
        mv "${_target}" "${_target}.backup"
    fi

    ln -sf "${_source}" "${_target}"
    printf '✅ Linked %s\n' "${_target}"
}

# Create symlinks (only if source exists)
if [ -f "${DOTFILES_DIR}/configs/terminal/tmux/tmux.conf" ]; then
    create_symlink "${DOTFILES_DIR}/configs/terminal/tmux/tmux.conf" "${HOME}/.tmux.conf"
else
    printf '⚠️  Skipping .tmux.conf (source not found)\n'
fi

# Create zsh config symlinks if they exist
if [ -f "${DOTFILES_DIR}/configs/shell/zsh/.zshenv" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/.zshenv" "${HOME}/.zshenv"
else
    printf '⚠️  Skipping .zshenv (source not found)\n'
fi

if [ -f "${DOTFILES_DIR}/configs/shell/zsh/.zshrc" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/.zshrc" "${HOME}/.zshrc"
else
    printf '⚠️  Skipping .zshrc (source not found)\n'
fi

if [ -f "${DOTFILES_DIR}/configs/shell/inputrc" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/inputrc" "${HOME}/.inputrc"
else
    printf '⚠️  Skipping .inputrc (source not found)\n'
fi
# Create nvim config directory and symlink
mkdir -p "${HOME}/.config"
create_symlink "${DOTFILES_DIR}/configs/editor/nvim" "${HOME}/.config/nvim"

# Create ~/.vim symlink for backward compatibility with existing vim config
create_symlink "${DOTFILES_DIR}/configs/editor/nvim" "${HOME}/.vim"

# Create mise config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/mise/config.toml" ]; then
    mkdir -p "${HOME}/.config/mise"
    create_symlink "${DOTFILES_DIR}/configs/tools/mise/config.toml" "${HOME}/.config/mise/config.toml"
fi

# Create tool-versions symlink if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/mise/tool-versions" ]; then
    create_symlink "${DOTFILES_DIR}/configs/tools/mise/tool-versions" "${HOME}/.tool-versions"
fi

# Create atuin config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/atuin/config.toml" ]; then
    mkdir -p "${HOME}/.config/atuin"
    create_symlink "${DOTFILES_DIR}/configs/tools/atuin/config.toml" "${HOME}/.config/atuin/config.toml"
fi

# Create gitignore_global if it exists
if [ -f "${DOTFILES_DIR}/configs/git/.gitignore_global" ]; then
    create_symlink "${DOTFILES_DIR}/configs/git/.gitignore_global" "${HOME}/.gitignore_global"
fi

# Create GitHub CLI config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/gh/config.yml" ]; then
    mkdir -p "${HOME}/.config/gh"
    create_symlink "${DOTFILES_DIR}/configs/tools/gh/config.yml" "${HOME}/.config/gh/config.yml"
fi

# Create k9s config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/k9s/config.yaml" ]; then
    mkdir -p "${HOME}/.config/k9s"
    create_symlink "${DOTFILES_DIR}/configs/tools/k9s/config.yaml" "${HOME}/.config/k9s/config.yaml"
fi

# Create htop config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/htop/htoprc" ]; then
    mkdir -p "${HOME}/.config/htop"
    create_symlink "${DOTFILES_DIR}/configs/tools/htop/htoprc" "${HOME}/.config/htop/htoprc"
fi

# Create glow config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/glow/glow.yml" ]; then
    mkdir -p "${HOME}/.config/glow"
    create_symlink "${DOTFILES_DIR}/configs/tools/glow/glow.yml" "${HOME}/.config/glow/glow.yml"
fi

# Create bat config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/bat/config" ]; then
    mkdir -p "${HOME}/.config/bat"
    create_symlink "${DOTFILES_DIR}/configs/tools/bat/config" "${HOME}/.config/bat/config"
fi

# Create tig config if it exists
if [ -f "${DOTFILES_DIR}/configs/tools/tig/tigrc" ]; then
    create_symlink "${DOTFILES_DIR}/configs/tools/tig/tigrc" "${HOME}/.tigrc"
fi

# Create zsh directory and symlink aliases and functions (with existence checks)
mkdir -p "${HOME}/.zsh"

if [ -f "${DOTFILES_DIR}/configs/shell/zsh/aliases.zsh" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/aliases.zsh" "${HOME}/.zsh/aliases.zsh"
else
    printf '⚠️  Skipping aliases.zsh (source not found)\n'
fi

if [ -f "${DOTFILES_DIR}/configs/shell/zsh/functions.zsh" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/functions.zsh" "${HOME}/.zsh/functions.zsh"
else
    printf '⚠️  Skipping functions.zsh (source not found)\n'
fi

if [ -f "${DOTFILES_DIR}/configs/shell/zsh/_completions.zsh" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/_completions.zsh" "${HOME}/.zsh/_completions.zsh"
else
    printf '⚠️  Skipping _completions.zsh (source not found)\n'
fi

# Create antidote plugins file symlink
if [ -f "${DOTFILES_DIR}/configs/shell/zsh/.zsh_plugins.txt" ]; then
    create_symlink "${DOTFILES_DIR}/configs/shell/zsh/.zsh_plugins.txt" "${HOME}/.zsh_plugins.txt"
fi

mkdir -p "${HOME}/.zsh/completions"

# Create local directories if they don't exist
mkdir -p "${HOME}/.local/share/zsh"
mkdir -p "${HOME}/.local/share/nvim"
mkdir -p "${HOME}/.config"

printf '✅ Symlink setup complete!\n'
