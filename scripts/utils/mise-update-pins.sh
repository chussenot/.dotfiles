#!/bin/sh
# Check for outdated mise-managed tools and bump their pinned versions.
#
# Thin wrapper over mise's native commands:
#   mise outdated --bump   shows pinned-vs-latest (compares against latest,
#                          not just the configured range)
#   mise upgrade  --bump   installs the latest and rewrites the pin in the
#                          config file where each tool is defined
#
# Run from the dotfiles repo so repo-scoped config and the conf.d/*.toml
# pins (symlinked into ~/.config/mise/conf.d) resolve. mise writes each bump
# back through the symlink to the repo file that defines the tool.
#
# NOTE: mise bumps the *active* definition of a tool. The few tools pinned in
# both the root mise.toml and conf.d/ (hk, pkl, prettier, shellcheck) bump in
# root, which takes precedence inside the repo. De-duplicate them if drift
# between the two locations matters.
#
# Usage: mise-update-pins.sh [--check|-c] [--batch|-b] [--dry-run|-n] [--help|-h]
#   (no args)     interactive multiselect of which tools to bump
#   -c, --check   read-only report of pinned vs latest
#   -b, --batch   bump all outdated tools without prompting
#   -n, --dry-run show what would change without modifying files

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

_mode="interactive"

for _arg in "$@"; do
  case "$_arg" in
  --batch | -b) _mode="batch" ;;
  --dry-run | -n) _mode="dry-run" ;;
  --check | -c) _mode="check" ;;
  --help | -h)
    sed -n '19,23p' "$0"
    exit 0
    ;;
  *)
    printf "Unknown option: %s\nRun with --help for usage.\n" "$_arg" >&2
    exit 1
    ;;
  esac
done

if ! command -v mise >/dev/null 2>&1; then
  printf "Error: mise not found in PATH\n" >&2
  exit 1
fi

cd "${DOTFILES_DIR}"

case "${_mode}" in
check) mise outdated --bump ;;
dry-run) mise upgrade --bump --dry-run ;;
batch) mise upgrade --bump ;;
interactive) mise upgrade --bump --interactive ;;
esac
