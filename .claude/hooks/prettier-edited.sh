#!/bin/sh
# PostToolUse(Edit|Write) hook: format an edited file with prettier so it never
# reaches the hk pre-push prettier --check gate unformatted (the hk pre-commit
# step already fixes on commit; this fixes earlier, on edit).
#
# --ignore-unknown lets prettier skip files it has no parser for (*.sh, *.toml,
# *.pkl, *.ron, ...), so shellcheck/pkl stay responsible for those. prettier
# discovers config and .prettierignore by walking up from the file path.
#
# ponytail: no-ops unless both jq and prettier are present. Always exits 0 so a
# format failure never blocks an edit.
set -eu

command -v jq >/dev/null 2>&1 || exit 0
command -v prettier >/dev/null 2>&1 || exit 0

_path=$(jq -r '.tool_input.file_path // empty')
[ -n "${_path}" ] || exit 0
[ -f "${_path}" ] || exit 0

if _out=$(prettier --write --ignore-unknown "${_path}" 2>&1); then
  # Empty output = file skipped (no parser, or ignored); "(unchanged)" = already
  # formatted. Both are silent. Anything else means prettier rewrote the file.
  case "${_out}" in
  '' | *unchanged*) ;;
  *) printf 'prettier formatted %s\n' "${_path}" >&2 ;;
  esac
else
  printf 'prettier could not format %s:\n%s\n' "${_path}" "${_out}" >&2
fi

exit 0
