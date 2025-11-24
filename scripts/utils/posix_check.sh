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

# Get script directory
_get_script_dir() {
    _script_path="$0"
    _script_dir=""
    case "${_script_path}" in
        /*)
            _script_dir=$(dirname "${_script_path}")
            ;;
        *)
            _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
            ;;
    esac
    printf '%s\n' "${_script_dir}"
}

SCRIPT_DIR=$(_get_script_dir)
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

# Check if file is a shell script
_is_shell_script() {
    _file="$1"
    # Check for .sh extension
    case "${_file}" in
        *.sh)
            return 0
            ;;
    esac
    # Check for shebang
    if [ -f "${_file}" ] && [ -r "${_file}" ]; then
        _first_line=$(head -n 1 "${_file}" 2>/dev/null || printf '')
        case "${_first_line}" in
            \#!/bin/sh|\#!/usr/bin/env\ sh|\#!/usr/bin/sh)
                return 0
                ;;
        esac
    fi
    return 1
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

# Check script with posh (if available)
_check_posh() {
    _file="$1"
    if _command_exists posh; then
        if posh -n "${_file}" >/dev/null 2>&1; then
            return 0
        else
            posh -n "${_file}" 2>&1 || true
            return 1
        fi
    else
        return 2
    fi
}

# Validate a single script
_validate_script() {
    _file="$1"
    _rel_path="${_file#${PROJECT_ROOT}/}"

    TOTAL=$((TOTAL + 1))

    _print_status "Checking: ${_rel_path}"

    # Check shellcheck
    _shellcheck_result=0
    _check_shellcheck "${_file}" || _shellcheck_result=$?

    # Check posh
    _posh_result=0
    _check_posh "${_file}" || _posh_result=$?

    # Determine result
    if [ "${_shellcheck_result}" -eq 2 ] && [ "${_posh_result}" -eq 2 ]; then
        _print_warning "No validation tools available, skipping ${_rel_path}"
        SKIPPED=$((SKIPPED + 1))
        return 0
    fi

    if [ "${_shellcheck_result}" -eq 0 ] && [ "${_posh_result}" -ne 1 ]; then
        _print_success "${_rel_path}"
        PASSED=$((PASSED + 1))
        return 0
    else
        _print_error "${_rel_path}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Find all shell scripts
_find_shell_scripts() {
    find "${PROJECT_ROOT}" -type f -name "*.sh" | sort
}

# Main execution
main() {
    _print_status "Starting POSIX compliance check..."
    _print_status "Project root: ${PROJECT_ROOT}"
    printf '\n'

    # Check for validation tools
    if ! _command_exists shellcheck && ! _command_exists posh; then
        _print_warning "No validation tools found!"
        _print_warning "Install shellcheck: https://github.com/koalaman/shellcheck"
        _print_warning "Install posh: https://salsa.debian.org/clint/posh"
        printf '\n'
    fi

    # Find and validate all scripts
    _errors=0
    for _script in $(_find_shell_scripts); do
        if _is_shell_script "${_script}"; then
            if ! _validate_script "${_script}"; then
                _errors=$((_errors + 1))
            fi
            printf '\n'
        fi
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
