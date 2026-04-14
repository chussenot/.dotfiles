#!/bin/sh
_mise="${HOME}/.local/bin/mise"

if ! command -v gh >/dev/null 2>&1 && ! "$_mise" which gh >/dev/null 2>&1; then
  printf 'gh is not installed. Run: mise install gh\n'
  printf 'Press Enter to close.'
  read -r _dummy
  exit 1
fi

if ! "$_mise" x -- gh extension list 2>/dev/null | grep -q 'gh-dash'; then
  printf 'gh-dash extension not installed.\n'
  printf 'Installing...\n\n'
  if ! "$_mise" x -- gh extension install dlvhdr/gh-dash; then
    printf '\nInstallation failed. Press Enter to close.'
    read -r _dummy
    exit 1
  fi
  printf '\nInstalled. Starting gh-dash...\n'
fi

exec "$_mise" x -- gh dash
