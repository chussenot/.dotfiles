#!/bin/sh

# Symlink setup script
# POSIX-compliant version
# Reads symlink mappings from symlinks.conf

set -eu

printf '🔗 Setting up symlinks...\n'

DOTFILES_DIR="${HOME}/.dotfiles"

# Resolve path to symlinks.conf relative to this script
_script_path="$0"
case "${_script_path}" in
/*)
  _script_dir=$(dirname "${_script_path}")
  ;;
*)
  _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
  ;;
esac
_conf_file="${_script_dir}/symlinks.conf"

if [ ! -f "${_conf_file}" ]; then
  printf '❌ symlinks.conf not found at %s\n' "${_conf_file}"
  exit 1
fi

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

# Read symlinks.conf and create each symlink
while IFS= read -r _line || [ -n "${_line}" ]; do
  # Skip comments and blank lines
  case "${_line}" in
    "#"*|"") continue ;;
  esac

  _src_rel=$(printf '%s' "${_line}" | cut -d'|' -f1)
  _tgt_tpl=$(printf '%s' "${_line}" | cut -d'|' -f2)

  _source="${DOTFILES_DIR}/${_src_rel}"
  # Expand $HOME in target path
  _target=$(eval printf '%s' "${_tgt_tpl}")

  if [ -e "${_source}" ]; then
    create_symlink "${_source}" "${_target}"
  else
    printf '⚠️  Skipping %s (source not found)\n' "${_src_rel}"
  fi
done < "${_conf_file}"

# Create supporting directories
mkdir -p "${HOME}/.zsh/completions"
mkdir -p "${HOME}/.local/share/zsh"
mkdir -p "${HOME}/.local/share/nvim"
mkdir -p "${HOME}/.config"

printf '✅ Symlink setup complete!\n'
