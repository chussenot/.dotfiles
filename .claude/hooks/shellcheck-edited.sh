#!/bin/sh
# PostToolUse(Edit|Write) hook: run shellcheck on an edited shell script under
# scripts/ or lib/ and surface findings. Advisory only — always exits 0 so it
# never blocks an edit (CI is the gate; this is fast local feedback).
#
# ponytail: no-ops unless both jq and shellcheck are present.
set -eu

command -v jq >/dev/null 2>&1 || exit 0
command -v shellcheck >/dev/null 2>&1 || exit 0

_path=$(jq -r '.tool_input.file_path // empty')
[ -n "${_path}" ] || exit 0

# Only POSIX shell scripts under scripts/ or lib/ are POSIX-gated (CLAUDE.md).
case "${_path}" in
*/scripts/*.sh | */lib/*.sh) ;;
*) exit 0 ;;
esac
[ -f "${_path}" ] || exit 0

if ! _out=$(shellcheck --shell=sh "${_path}" 2>&1); then
  printf 'shellcheck --shell=sh flagged %s:\n%s\n' "${_path}" "${_out}" >&2
fi

exit 0
