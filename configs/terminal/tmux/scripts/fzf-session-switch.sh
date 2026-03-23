#!/usr/bin/env bash
# fzf-powered tmux session/window switcher
# - Fuzzy search across all sessions and windows
# - Creates a new session if the query doesn't match anything

# display-popup uses a minimal env; activate mise so fzf is in PATH
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash 2>/dev/null)"
elif [ -f "${HOME}/.local/bin/mise" ]; then
  eval "$("${HOME}/.local/bin/mise" activate bash 2>/dev/null)"
fi

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
  local result retval query selection

  result=$(
    tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}" |
      fzf --exit-0 --print-query --reverse \
        --delimiter=":" --with-nth=1,2,4 \
        --preview 'session_name=$(echo {} | cut -d: -f1); window_index=$(echo {} | cut -d: -f2); target="${session_name}:${window_index}"; pane=$(tmux list-panes -t "$target" -F "#{pane_id} #{pane_active}" 2>/dev/null | awk "\$2 == \"1\" {print \$1}"); [ -n "$pane" ] && tmux capture-pane -ep -t "$pane"' \
        --preview-window=right:60%
  )
  retval=$?

  query=$(echo "$result" | head -1)
  selection=$(echo "$result" | sed -n '2p')

  if [ $retval -eq 0 ]; then
    # Match found — switch to the selected session:window
    if [ -z "$selection" ]; then
      selection="$query"
    fi
    local session_name window_index
    session_name=$(echo "$selection" | cut -d: -f1)
    window_index=$(echo "$selection" | cut -d: -f2)
    tmux switch-client -t "${session_name}:${window_index}"
  elif [ $retval -eq 1 ] && [ -n "$query" ]; then
    # No match — create a new session with the query as name
    tmux new-session -d -s "$query" 2>/dev/null &&
      tmux switch-client -t "$query"
  fi
}

main
