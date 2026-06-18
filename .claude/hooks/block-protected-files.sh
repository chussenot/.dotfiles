#!/bin/sh
# PreToolUse(Edit|Write) hook: refuse edits to the protected fzf files.
# Regenerating them reintroduces hardcoded /home/<user> paths (see CLAUDE.md
# "Protected Files"). Reads the hook payload from stdin and denies by exit 2.
#
# ponytail: fails OPEN if jq is missing (edit allowed) rather than blocking all
# edits. Install jq (already pinned in mise) for the guard to take effect.
set -eu

command -v jq >/dev/null 2>&1 || exit 0

_path=$(jq -r '.tool_input.file_path // empty')
[ -n "${_path}" ] || exit 0

case "${_path}" in
*/configs/shell/fzf/fzf.bash | */configs/shell/fzf/fzf.zsh)
  printf 'Blocked: %s is a protected fzf file (CLAUDE.md). ' "${_path}" >&2
  printf 'Regenerate with fzf --bash / --zsh and re-patch for portability instead.\n' >&2
  exit 2
  ;;
esac

exit 0
