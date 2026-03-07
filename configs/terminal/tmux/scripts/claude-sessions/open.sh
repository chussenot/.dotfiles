#!/usr/bin/env bash
# open.sh -- receives "<path>\t<session-id>" and opens claude -r in a tmux window.
# If a window for the session already exists, switches to it instead.

set -euo pipefail

INPUT="$1"
DIR=$(printf '%s' "$INPUT" | cut -f1)
SID=$(printf '%s' "$INPUT" | cut -f2)

[ -z "$DIR" ] && exit 0
[ -z "$SID" ] && exit 0
[ ! -d "$DIR" ] && {
  echo "claude-sessions: directory not found: $DIR" >&2
  exit 1
}

WIN_NAME="claude-${SID:0:8}"

# If a window for this session already exists, switch to it
existing=$(tmux list-windows -a -F "#{session_name}:#{window_name}" 2>/dev/null |
  grep ":${WIN_NAME}$" | head -1 || true)

if [ -n "$existing" ]; then
  tmux switch-client -t "$existing"
  exit 0
fi

# Create a new window and run claude -r
CURRENT_SESSION=$(tmux display-message -p '#S')
CURRENT_CLIENT=$(tmux display-message -p '#{client_name}')

tmux new-window -n "$WIN_NAME" -c "$DIR" -t "${CURRENT_SESSION}:"
tmux send-keys -t "${CURRENT_SESSION}:${WIN_NAME}" "claude -r ${SID}" Enter
tmux switch-client -c "$CURRENT_CLIENT" -t "${CURRENT_SESSION}:${WIN_NAME}"
