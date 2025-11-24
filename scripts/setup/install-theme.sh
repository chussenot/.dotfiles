#!/bin/sh

# Install chussenot zsh theme (symlink version)
# POSIX-compliant version

set -eu

# Get script directory (POSIX-compatible)
_get_script_dir() {
    _script_path="$0"
    _script_dir=""
    case "${_script_path}" in
        /*)
            _script_dir=$(dirname "${_script_path}")
            ;;
        *)
            _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
            ;;
    esac
    printf '%s\n' "${_script_dir}"
}

_script_dir=$(_get_script_dir)
DOTFILES_DIR=$(cd "${_script_dir}/../.." && pwd)
THEME_SOURCE="${DOTFILES_DIR}/configs/shell/chussenot.zsh-theme"
THEME_DEST="${HOME}/.oh-my-zsh/themes/chussenot.zsh-theme"

printf '🎨 Installing chussenot zsh theme using symlink...\n'

# Check if Oh-My-Zsh is installed
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    printf '❌ Oh-My-Zsh not found. Please install Oh-My-Zsh first.\n'
    printf '   Visit: https://ohmyz.sh/\n'
    exit 1
fi

# Check if source theme exists
if [ ! -f "${THEME_SOURCE}" ]; then
    printf '❌ Source theme not found: %s\n' "${THEME_SOURCE}"
    exit 1
fi

# Create themes directory if it doesn't exist
mkdir -p "${HOME}/.oh-my-zsh/themes"

# If symlink/file exists but is not correct, replace it
if [ -L "${THEME_DEST}" ] || [ -f "${THEME_DEST}" ]; then
    _current_link=""
    if [ -L "${THEME_DEST}" ]; then
        # POSIX-compatible readlink (may not work on all systems, but try)
        if command -v readlink >/dev/null 2>&1; then
            _current_link=$(readlink "${THEME_DEST}" 2>/dev/null || printf '')
        fi
    fi
    if [ "${_current_link}" != "${THEME_SOURCE}" ]; then
        printf '⚠️  Removing existing theme file: %s\n' "${THEME_DEST}"
        rm -f "${THEME_DEST}"
    fi
fi

# Create symlink to theme in Oh-My-Zsh themes directory
ln -sf "${THEME_SOURCE}" "${THEME_DEST}"
printf '✅ Symlink created: %s → %s\n' "${THEME_DEST}" "${THEME_SOURCE}"

# Check if theme is already set in zshrc
if grep -q 'ZSH_THEME="chussenot"' "${HOME}/.zshrc" 2>/dev/null; then
    printf '✅ Theme already set in .zshrc\n'
else
    printf '⚠️  Theme not set in .zshrc yet\n'
    printf '   You may need to set ZSH_THEME="chussenot" in your .zshrc\n'
fi

printf '\n'
printf '🎉 Installation complete!\n'
printf '\n'
printf 'To use the theme:\n'
printf '  1. Set ZSH_THEME="chussenot" in your .zshrc\n'
printf '  2. Reload your shell: source ~/.zshrc\n'
printf '  3. Or start a new terminal session\n'
printf '\n'
printf 'The theme features:\n'
printf '  - Git/SVN/HG version control status\n'
printf '  - Virtual environment support\n'
printf '  - Exit code display\n'
printf '  - Timestamp information\n'
printf '  - Clean, colorful formatting\n'
