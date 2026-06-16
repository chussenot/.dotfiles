#!/bin/sh

# POSIX Compliance Checker
# This script validates all shell scripts for POSIX compliance
# POSIX-compliant version

set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory (cd+pwd canonicalizes for absolute and relative $0)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "${SCRIPT_DIR}/../.." && pwd)

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Check if a command exists
_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Print status
_print_status() {
  printf '%b[INFO]%b %s\n' "${BLUE}" "${NC}" "$1"
}

_print_success() {
  printf '%b[PASS]%b %s\n' "${GREEN}" "${NC}" "$1"
}

_print_error() {
  printf '%b[FAIL]%b %s\n' "${RED}" "${NC}" "$1"
}

_print_warning() {
  printf '%b[WARN]%b %s\n' "${YELLOW}" "${NC}" "$1"
}

# Check script with shellcheck
_check_shellcheck() {
  _file="$1"
  if _command_exists shellcheck; then
    if shellcheck --shell=sh "${_file}" >/dev/null 2>&1; then
      return 0
    else
      shellcheck --shell=sh "${_file}" 2>&1 || true
      return 1
    fi
  else
    _print_warning "shellcheck not found, skipping shellcheck validation"
    return 2
  fi
}

# Validate a single script with shellcheck
_validate_script() {
  _file="$1"
  _rel_path="${_file#"${PROJECT_ROOT}"/}"

  TOTAL=$((TOTAL + 1))

  _print_status "Checking: ${_rel_path}"

  _shellcheck_result=0
  _check_shellcheck "${_file}" || _shellcheck_result=$?

  if [ "${_shellcheck_result}" -eq 2 ]; then
    _print_warning "No validation tool available, skipping ${_rel_path}"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ "${_shellcheck_result}" -eq 0 ]; then
    _print_success "${_rel_path}"
    PASSED=$((PASSED + 1))
    return 0
  else
    _print_error "${_rel_path}"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

# Find all shell scripts (exclude configs/ folder and transient git worktrees)
_find_shell_scripts() {
  find "${PROJECT_ROOT}" -type f -name "*.sh" \
    ! -path "${PROJECT_ROOT}/configs/*" \
    ! -path "${PROJECT_ROOT}/.claude/worktrees/*" \
    ! -path "${PROJECT_ROOT}/tmp/*" | sort
}

# Main execution
main() {
  _print_status "Starting POSIX compliance check..."
  _print_status "Project root: ${PROJECT_ROOT}"
  printf '\n'

  # Check for validation tool
  if ! _command_exists shellcheck; then
    _print_warning "shellcheck not found!"
    _print_warning "Install shellcheck: https://github.com/koalaman/shellcheck"
    printf '\n'
  fi

  # Find and validate all scripts
  _errors=0
  for _script in $(_find_shell_scripts); do
    if ! _validate_script "${_script}"; then
      _errors=$((_errors + 1))
    fi
    printf '\n'
  done

  # Summary
  printf '\n'
  _print_status "=== Summary ==="
  printf 'Total scripts: %d\n' "${TOTAL}"
  _print_success "Passed: ${PASSED}"
  if [ "${FAILED}" -gt 0 ]; then
    _print_error "Failed: ${FAILED}"
  fi
  if [ "${SKIPPED}" -gt 0 ]; then
    _print_warning "Skipped: ${SKIPPED}"
  fi

  if [ "${_errors}" -eq 0 ]; then
    printf '\n'
    _print_success "✅ All scripts are POSIX-compliant!"
    exit 0
  else
    printf '\n'
    _print_error "❌ ${_errors} script(s) failed validation"
    exit 1
  fi
}

main "$@"
