#!/bin/sh
# Checks for outdated mise-managed tools and updates pinned versions
# in configs/tools/mise/conf.d/*.toml and the root mise.toml.
#
# Parses pinned versions directly from TOML files and compares each
# against `mise latest <tool>` to find available upgrades.
#
# Usage: mise-update-pins.sh [--batch|-b] [--dry-run|-n] [--help|-h]
#
# Interactive controls (default mode):
#   y   Update this tool
#   n   Skip this tool
#   a   Update all remaining tools without further prompting
#   q   Quit without further changes

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONF_D="${DOTFILES_DIR}/configs/tools/mise/conf.d"
ROOT_TOML="${DOTFILES_DIR}/mise.toml"

_batch=0
_dry_run=0

for _arg in "$@"; do
  case "$_arg" in
  --batch | -b) _batch=1 ;;
  --dry-run | -n) _dry_run=1 ;;
  --help | -h)
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Check for outdated mise-managed tools and update pinned versions.
Parses configs/tools/mise/conf.d/*.toml and mise.toml, then uses
\`mise latest\` to find available upgrades.

Options:
  -b, --batch    Update all outdated tools without prompting
  -n, --dry-run  Show what would change without modifying files
  -h, --help     Show this help

Interactive controls (default mode):
  y   Update this tool
  n   Skip this tool
  a   Update all remaining (switch to batch)
  q   Quit
EOF
    exit 0
    ;;
  *)
    printf "Unknown option: %s\nRun with --help for usage.\n" "$_arg" >&2
    exit 1
    ;;
  esac
done

# --- Validate dependencies ---

if ! command -v mise >/dev/null 2>&1; then
  printf "Error: mise not found in PATH\n" >&2
  exit 1
fi

if [ ! -d "$CONF_D" ]; then
  printf "Error: conf.d not found: %s\n" "$CONF_D" >&2
  exit 1
fi

# --- Portable sed -i (GNU vs BSD) ---

case "$(uname -s)" in
Darwin) _sed_inplace() { sed -i '' "$@"; } ;;
*) _sed_inplace() { sed -i "$@"; } ;;
esac

# --- Create temp directory ---

_tmpdir=$(mktemp -d)
trap 'rm -rf "$_tmpdir"' EXIT INT TERM

_tools_file="${_tmpdir}/tools"
_outdated_file="${_tmpdir}/outdated"

# --- Parse TOML files ---
# Extract: tool|pinned_version|file_path  (pipe-delimited)

awk '
/^[[:space:]]*#/ { next }
/^[[:space:]]*\[/ { next }
/^[[:space:]]*$/ { next }
/= *"/ {
  line = $0
  eq = index(line, "=")
  if (eq == 0) next
  key = substr(line, 1, eq - 1)
  val_part = substr(line, eq + 1)
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
  if (substr(key, 1, 1) == "\"")
    key = substr(key, 2, length(key) - 2)
  q1 = index(val_part, "\"")
  if (q1 == 0) next
  rest = substr(val_part, q1 + 1)
  q2 = index(rest, "\"")
  if (q2 == 0) next
  version = substr(rest, 1, q2 - 1)
  if (key != "" && version != "")
    printf "%s|%s|%s\n", key, version, FILENAME
}
' "$CONF_D"/*.toml "$ROOT_TOML" >"$_tools_file"

_total=$(wc -l <"$_tools_file" | tr -d ' ')
if [ "$_total" -eq 0 ]; then
  printf "No tools found in TOML files.\n"
  exit 0
fi

printf "Scanning %s tools for updates...\n" "$_total"

# --- Check each tool against `mise latest` (parallel batches) ---

_max_jobs=8
_n=0
_running=0

while IFS='|' read -r _tool _pinned _file; do
  _n=$((_n + 1))
  (
    _latest=$(mise latest "$_tool" 2>/dev/null) || true
    printf '%s\n' "${_tool}|${_pinned}|${_latest}|${_file}"
  ) >"${_tmpdir}/r${_n}" &
  _running=$((_running + 1))
  if [ "$_running" -ge "$_max_jobs" ]; then
    wait
    _running=0
    printf "  checked %d/%d\n" "$_n" "$_total"
  fi
done <"$_tools_file"
wait

if [ "$_running" -gt 0 ]; then
  printf "  checked %d/%d\n" "$_n" "$_total"
fi

# --- Collect outdated results ---

_i=1
while [ "$_i" -le "$_n" ]; do
  _result="${_tmpdir}/r${_i}"
  if [ -s "$_result" ]; then
    IFS='|' read -r _tool _pinned _latest _file <"$_result"
    if [ -n "$_latest" ] && [ "$_pinned" != "$_latest" ]; then
      printf '%s\n' "${_tool}|${_pinned}|${_latest}|${_file}" >>"$_outdated_file"
    fi
  fi
  _i=$((_i + 1))
done

if [ ! -s "$_outdated_file" ]; then
  printf "All %s tools are up to date.\n" "$_total"
  exit 0
fi

_outdated_count=$(wc -l <"$_outdated_file" | tr -d ' ')
printf "\nFound %s outdated tool(s):\n\n" "$_outdated_count"

# --- Print summary ---

while IFS='|' read -r _tool _pinned _latest _file; do
  printf "  %-55s %s -> %s  (%s)\n" "$_tool" "$_pinned" "$_latest" "${_file##*/}"
done <"$_outdated_file"
printf "\n"

# --- Update function ---

do_update() {
  _file="$1"
  _tool="$2"
  _old="$3"
  _new="$4"

  if [ "$_dry_run" = "1" ]; then
    printf "  [dry-run] %-50s %s -> %s\n" "$_tool" "$_old" "$_new"
    return 0
  fi

  # quoted key: "tool:path" = "old" -> "tool:path" = "new"
  if grep -qF "\"${_tool}\" = \"${_old}\"" "$_file" 2>/dev/null; then
    _sed_inplace "s|\"${_tool}\" = \"${_old}\"|\"${_tool}\" = \"${_new}\"|" "$_file"
    printf "  [updated] %-50s %s -> %s  (%s)\n" \
      "$_tool" "$_old" "$_new" "${_file##*/}"
    return 0
  fi

  # bare key: tool = "old" -> tool = "new"
  if grep -q "^${_tool} = \"${_old}\"" "$_file" 2>/dev/null; then
    _sed_inplace "s|^${_tool} = \"${_old}\"|${_tool} = \"${_new}\"|" "$_file"
    printf "  [updated] %-50s %s -> %s  (%s)\n" \
      "$_tool" "$_old" "$_new" "${_file##*/}"
    return 0
  fi

  printf "  [error]   Could not locate %s = \"%s\" in %s\n" \
    "$_tool" "$_old" "${_file##*/}" >&2
}

# --- Main update loop ---

while IFS='|' read -r _tool _pinned _latest _file; do
  if [ "$_batch" = "1" ]; then
    do_update "$_file" "$_tool" "$_pinned" "$_latest"
  else
    printf "  %-50s %s -> %s  [y/n/a/q] " "$_tool" "$_pinned" "$_latest"
    read -r _answer </dev/tty
    case "$_answer" in
    y | Y) do_update "$_file" "$_tool" "$_pinned" "$_latest" ;;
    a | A)
      _batch=1
      do_update "$_file" "$_tool" "$_pinned" "$_latest"
      ;;
    q | Q)
      printf "Quit.\n"
      exit 0
      ;;
    *) printf "  [skipped] %s\n" "$_tool" ;;
    esac
  fi
done <"$_outdated_file"

printf "\n"
if [ "$_dry_run" = "1" ]; then
  printf "Dry run complete. Run without --dry-run to apply changes.\n"
else
  printf "Done. Run 'mise install' to install updated versions.\n"
fi
