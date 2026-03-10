#!/bin/sh
# Toggle mise tool groups on/off.
#
# Disabled groups are renamed with a .disabled suffix so mise ignores them.
# The 01-languages and 02-essentials groups cannot be disabled.
#
# Usage: mise-toggle-groups.sh [--list|-l] [--enable|-e NAME] [--disable|-d NAME] [--help|-h]
#   No arguments: interactive mode (requires fzf)

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONF_D="${DOTFILES_DIR}/configs/tools/mise/conf.d"

PROTECTED="01-languages 02-essentials"

usage() {
  cat <<'EOF'
Usage: mise-toggle-groups.sh [OPTIONS]

Toggle mise tool groups on/off.

Options:
  -l, --list             List groups and their status
  -e, --enable  NAME     Enable a disabled group
  -d, --disable NAME     Disable an enabled group
  -h, --help             Show this help

Without options: interactive mode using fzf (multi-select).
EOF
}

# Extract group name from filename (strip number prefix, extension, .disabled)
group_name() {
  _basename="$(basename "$1")"
  echo "${_basename}" | sed 's/\.disabled$//' | sed 's/\.toml$//'
}

is_protected() {
  _name="$1"
  for _p in ${PROTECTED}; do
    if [ "${_name}" = "${_p}" ]; then
      return 0
    fi
  done
  return 1
}

list_groups() {
  for _f in "${CONF_D}"/*.toml "${CONF_D}"/*.toml.disabled; do
    [ -f "${_f}" ] || continue
    _name="$(group_name "${_f}")"
    case "${_f}" in
    *.disabled) _status="disabled" ;;
    *) _status="enabled" ;;
    esac
    if is_protected "${_name}"; then
      _lock=" (protected)"
    else
      _lock=""
    fi
    printf "  %-30s %s%s\n" "${_name}" "${_status}" "${_lock}"
  done
}

enable_group() {
  _target="$1"
  _file="${CONF_D}/${_target}.toml.disabled"
  if [ ! -f "${_file}" ]; then
    echo "Group '${_target}' is not disabled or does not exist." >&2
    return 1
  fi
  mv "${_file}" "${CONF_D}/${_target}.toml"
  echo "Enabled: ${_target}"
}

disable_group() {
  _target="$1"
  if is_protected "${_target}"; then
    echo "Cannot disable protected group '${_target}'." >&2
    return 1
  fi
  _file="${CONF_D}/${_target}.toml"
  if [ ! -f "${_file}" ]; then
    echo "Group '${_target}' is not enabled or does not exist." >&2
    return 1
  fi
  mv "${_file}" "${CONF_D}/${_target}.toml.disabled"
  echo "Disabled: ${_target}"
}

interactive_mode() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for interactive mode. Use --list, --enable, or --disable instead." >&2
    exit 1
  fi

  # Build list showing current state
  _items=""
  for _f in "${CONF_D}"/*.toml "${CONF_D}"/*.toml.disabled; do
    [ -f "${_f}" ] || continue
    _name="$(group_name "${_f}")"
    is_protected "${_name}" && continue
    case "${_f}" in
    *.disabled) _items="${_items}[off] ${_name}\n" ;;
    *) _items="${_items}[on]  ${_name}\n" ;;
    esac
  done

  # Selected items get toggled (on→off, off→on)
  _selected="$(printf '%b' "${_items}" | sed '/^$/d' | fzf --multi \
    --header="Select groups to TOGGLE (TAB select, ENTER confirm, ESC cancel)" \
    --prompt="Toggle> " \
    --preview="cat '${CONF_D}/{2}.toml' 2>/dev/null || cat '${CONF_D}/{2}.toml.disabled' 2>/dev/null" |
    cat || true)"

  if [ -z "${_selected}" ]; then
    echo "Cancelled, no changes."
    return
  fi

  # Toggle each selected group
  echo "${_selected}" | while IFS= read -r _line; do
    [ -z "${_line}" ] && continue
    _state="$(echo "${_line}" | awk '{print $1}')"
    _name="$(echo "${_line}" | awk '{print $2}')"
    case "${_state}" in
    "[on]") disable_group "${_name}" ;;
    "[off]") enable_group "${_name}" ;;
    esac
  done

  echo ""
  echo "Current status:"
  list_groups
}

# --- Main ---

if [ $# -eq 0 ]; then
  interactive_mode
  exit 0
fi

case "$1" in
-l | --list)
  list_groups
  ;;
-e | --enable)
  [ $# -lt 2 ] && {
    echo "Missing group name." >&2
    exit 1
  }
  enable_group "$2"
  ;;
-d | --disable)
  [ $# -lt 2 ] && {
    echo "Missing group name." >&2
    exit 1
  }
  disable_group "$2"
  ;;
-h | --help)
  usage
  ;;
*)
  echo "Unknown option: $1" >&2
  usage >&2
  exit 1
  ;;
esac
