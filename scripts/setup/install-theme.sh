#!/bin/sh

# Install chussenot zsh theme (supports both Oh-My-Zsh and standalone)
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
THEME_DEST_OMZ="${HOME}/.oh-my-zsh/themes/chussenot.zsh-theme"
THEME_DEST_STANDALONE="${HOME}/.zsh/themes/chussenot.zsh-theme"

printf '🎨 Installing chussenot zsh theme...\n'

# Check if source theme exists
if [ ! -f "${THEME_SOURCE}" ]; then
    printf '❌ Source theme not found: %s\n' "${THEME_SOURCE}"
    exit 1
fi

# Install for Oh-My-Zsh if available
if [ -d "${HOME}/.oh-my-zsh" ]; then
    printf '📦 Installing theme for Oh-My-Zsh...\n'

    # Create themes directory if it doesn't exist
    mkdir -p "${HOME}/.oh-my-zsh/themes"

    # If symlink/file exists but is not correct, replace it
    if [ -L "${THEME_DEST_OMZ}" ] || [ -f "${THEME_DEST_OMZ}" ]; then
        _current_link=""
        if [ -L "${THEME_DEST_OMZ}" ]; then
            # POSIX-compatible readlink (may not work on all systems, but try)
            if command -v readlink >/dev/null 2>&1; then
                _current_link=$(readlink "${THEME_DEST_OMZ}" 2>/dev/null || printf '')
            fi
        fi
        if [ "${_current_link}" != "${THEME_SOURCE}" ]; then
            printf '⚠️  Removing existing theme file: %s\n' "${THEME_DEST_OMZ}"
            rm -f "${THEME_DEST_OMZ}"
        fi
    fi

    # Create symlink to theme in Oh-My-Zsh themes directory
    ln -sf "${THEME_SOURCE}" "${THEME_DEST_OMZ}"
    printf '✅ Symlink created: %s → %s\n' "${THEME_DEST_OMZ}" "${THEME_SOURCE}"
fi

# Install standalone version (always, for use without Oh-My-Zsh)
printf '📦 Installing standalone theme...\n'

# Create themes directory if it doesn't exist
mkdir -p "${HOME}/.zsh/themes"

# If symlink/file exists but is not correct, replace it
if [ -L "${THEME_DEST_STANDALONE}" ] || [ -f "${THEME_DEST_STANDALONE}" ]; then
    _current_link=""
    if [ -L "${THEME_DEST_STANDALONE}" ]; then
        if command -v readlink >/dev/null 2>&1; then
            _current_link=$(readlink "${THEME_DEST_STANDALONE}" 2>/dev/null || printf '')
        fi
    fi
    if [ "${_current_link}" != "${THEME_SOURCE}" ]; then
        printf '⚠️  Removing existing theme file: %s\n' "${THEME_DEST_STANDALONE}"
        rm -f "${THEME_DEST_STANDALONE}"
    fi
fi

# Create symlink to theme in standalone themes directory
ln -sf "${THEME_SOURCE}" "${THEME_DEST_STANDALONE}"
printf '✅ Symlink created: %s → %s\n' "${THEME_DEST_STANDALONE}" "${THEME_SOURCE}"

# Check if theme is already configured in zshrc
if grep -q 'ZSH_THEME="chussenot"' "${HOME}/.zshrc" 2>/dev/null || \
   grep -q 'source.*chussenot.zsh-theme' "${HOME}/.zshrc" 2>/dev/null; then
    printf '✅ Theme already configured in .zshrc\n'
else
    printf '⚠️  Theme not configured in .zshrc yet\n'
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        printf '   Set ZSH_THEME="chussenot" in your .zshrc (Oh-My-Zsh mode)\n'
    else
        printf '   Add: source ~/.zsh/themes/chussenot.zsh-theme\n'
        printf '   Or: source %s\n' "${THEME_SOURCE}"
    fi
fi

printf '\n'
printf '🎉 Installation complete!\n'
printf '\n'
printf 'To use the theme:\n'
if [ -d "${HOME}/.oh-my-zsh" ]; then
    printf '  With Oh-My-Zsh: Set ZSH_THEME="chussenot" in your .zshrc\n'
fi
printf '  Standalone: Add "source ~/.zsh/themes/chussenot.zsh-theme" to your .zshrc\n'
printf '  2. Reload your shell: source ~/.zshrc\n'
printf '  3. Or start a new terminal session\n'
printf '\n'
printf 'The theme features:\n'
printf '  - Git version control status (works without Oh-My-Zsh)\n'
printf '  - Virtual environment support\n'
printf '  - Exit code display\n'
printf '  - Python/Node.js/Go version display\n'
printf '  - System load and background jobs\n'
printf '  - Docker container indicator\n'
printf '  - Clean, colorful formatting\n'
