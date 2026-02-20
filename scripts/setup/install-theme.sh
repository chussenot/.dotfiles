#!/bin/sh

# Install chussenot zsh theme (standalone, no Oh-My-Zsh required)
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
THEME_DEST="${HOME}/.zsh/themes/chussenot.zsh-theme"

printf '🎨 Installing chussenot zsh theme...\n'

# Check if source theme exists
if [ ! -f "${THEME_SOURCE}" ]; then
  printf '❌ Source theme not found: %s\n' "${THEME_SOURCE}"
  exit 1
fi

# Install standalone version
printf '📦 Installing standalone theme...\n'

# Create themes directory if it doesn't exist
mkdir -p "${HOME}/.zsh/themes"

# If symlink/file exists but is not correct, replace it
if [ -L "${THEME_DEST}" ] || [ -f "${THEME_DEST}" ]; then
  _current_link=""
  if [ -L "${THEME_DEST}" ]; then
    if command -v readlink >/dev/null 2>&1; then
      _current_link=$(readlink "${THEME_DEST}" 2>/dev/null || printf '')
    fi
  fi
  if [ "${_current_link}" != "${THEME_SOURCE}" ]; then
    printf '⚠️  Removing existing theme file: %s\n' "${THEME_DEST}"
    rm -f "${THEME_DEST}"
  fi
fi

# Create symlink to theme
ln -sf "${THEME_SOURCE}" "${THEME_DEST}"
printf '✅ Symlink created: %s → %s\n' "${THEME_DEST}" "${THEME_SOURCE}"

# Check if theme is already configured in zshrc
if grep -q 'source.*chussenot.zsh-theme' "${HOME}/.zshrc" 2>/dev/null; then
  printf '✅ Theme already configured in .zshrc\n'
else
  printf '⚠️  Theme not configured in .zshrc yet\n'
  printf '   The theme should be automatically loaded by your .zshrc\n'
  printf '   If not, add: source ~/.zsh/themes/chussenot.zsh-theme\n'
fi

printf '\n'
printf '🎉 Installation complete!\n'
printf '\n'
printf 'The theme is now installed and will be loaded automatically.\n'
printf 'To apply changes:\n'
printf '  1. Reload your shell: source ~/.zshrc\n'
printf '  2. Or start a new terminal session\n'
printf '\n'
printf 'The theme features:\n'
printf '  - Git version control status (standalone, no Oh-My-Zsh required)\n'
printf '  - Virtual environment support\n'
printf '  - Exit code display\n'
printf '  - Python/Node.js/Go version display\n'
printf '  - System load and background jobs\n'
printf '  - Docker container indicator\n'
printf '  - Clean, colorful formatting\n'
