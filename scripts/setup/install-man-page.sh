#!/bin/sh

# Install man page for keymaps function
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
MAN_SOURCE="${DOTFILES_DIR}/man/man1/keymaps.1"
MAN_DEST="${HOME}/.local/share/man/man1/keymaps.1"

printf '📖 Installing keymaps man page...\n'

# Create man directory if it doesn't exist
mkdir -p "${HOME}/.local/share/man/man1"

# Copy man page
if [ -f "${MAN_SOURCE}" ]; then
    cp "${MAN_SOURCE}" "${MAN_DEST}"
    printf '✅ Man page copied to %s\n' "${MAN_DEST}"
else
    printf '❌ Source man page not found: %s\n' "${MAN_SOURCE}"
    exit 1
fi

# Update man database
if command -v mandb >/dev/null 2>&1; then
    mandb -q
    printf '✅ Man database updated\n'
else
    printf '⚠️  mandb not found, man page may not be immediately searchable\n'
fi

# Add to MANPATH if not already present in .zshrc
if [ -f "${HOME}/.zshrc" ]; then
    if grep -q '\.local/share/man' "${HOME}/.zshrc" 2>/dev/null; then
        printf '✅ MANPATH already configured in .zshrc\n'
    else
        # shellcheck disable=SC2016 # Intentionally not expanding ${MANPATH:-} - it goes into .zshrc
        printf 'export MANPATH="%s/.local/share/man:${MANPATH:-}"\n' "${HOME}" >> "${HOME}/.zshrc"
        printf '✅ Added ~/.local/share/man to MANPATH in .zshrc\n'
    fi
else
    printf '⚠️  .zshrc not found, cannot add MANPATH configuration\n'
    # shellcheck disable=SC2016 # Intentionally showing literal ${MANPATH:-} for user to copy
    printf '   Add manually: export MANPATH="%s/.local/share/man:${MANPATH:-}"\n' "${HOME}"
fi

printf '\n'
printf '🎉 Installation complete!\n'
printf '\n'
printf 'Usage:\n'
printf '  man keymaps    # View the manual page\n'
printf '\n'
printf 'The man page is now available system-wide.\n'
