#!/bin/sh

# Backup script for dotfiles
# POSIX-compliant version

set -eu

BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "${BACKUP_DIR}"

printf '💾 Creating backup in %s\n' "${BACKUP_DIR}"

# Backup existing dotfiles (using positional parameters)
_files_to_backup="
${HOME}/.zshrc
${HOME}/.tmux.conf
${HOME}/.inputrc
${HOME}/.config/nvim
${HOME}/.config/bat
${HOME}/.tool-versions
"

# Remove leading/trailing whitespace and iterate
for _file in ${_files_to_backup}; do
    # Skip empty lines
    [ -z "${_file}" ] && continue
    if [ -e "${_file}" ]; then
        cp -r "${_file}" "${BACKUP_DIR}/"
        printf '✅ Backed up %s\n' "${_file}"
    fi
done

printf '✅ Backup complete!\n'
