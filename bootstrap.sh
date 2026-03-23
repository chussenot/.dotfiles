#!/bin/sh

# Bootstrap script for dotfiles installation
# Clones the repository and runs the installer in one step.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/chussenot/dotfiles/master/bootstrap.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/chussenot/dotfiles/master/bootstrap.sh | sh -s -- --minimal
#   curl -fsSL https://raw.githubusercontent.com/chussenot/dotfiles/master/bootstrap.sh | sh -s -- --full

set -eu

DOTFILES_DIR="${HOME}/.dotfiles"
REPO_URL="https://github.com/chussenot/dotfiles.git"

if [ -d "${DOTFILES_DIR}" ]; then
  printf 'Dotfiles already exist at %s, pulling latest...\n' "${DOTFILES_DIR}"
  git -C "${DOTFILES_DIR}" pull --ff-only || {
    printf 'Pull failed. Resolve manually and re-run.\n' >&2
    exit 1
  }
else
  printf 'Cloning dotfiles into %s...\n' "${DOTFILES_DIR}"
  git clone --depth=1 "${REPO_URL}" "${DOTFILES_DIR}"
fi

cd "${DOTFILES_DIR}"
exec ./install.sh "$@"
