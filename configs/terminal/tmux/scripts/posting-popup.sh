#!/bin/sh
_mise="${HOME}/.local/bin/mise"

if ! "$_mise" which posting >/dev/null 2>&1; then
  printf 'posting is not installed. Run: mise install\n'
  printf 'Press Enter to close.'
  read -r _dummy
  exit 1
fi

exec "$_mise" x -- posting
