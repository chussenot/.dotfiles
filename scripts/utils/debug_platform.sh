#!/bin/sh

# Platform Detection Debug Script
# This script helps verify platform detection logic

set -eu

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

_script_dir=$(_get_script_dir)
_project_root=$(cd "${_script_dir}/../.." && pwd)

# Source platform detection module
# shellcheck disable=SC1091
. "${_project_root}/lib/platform.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

_print_header() {
    printf '%b%s%b\n' "${CYAN}" "$1" "${NC}"
}

_print_label() {
    printf '%b%s:%b ' "${BLUE}" "$1" "${NC}"
}

_print_value() {
    printf '%b%s%b\n' "${GREEN}" "$1" "${NC}"
}

_print_warning() {
    printf '%b%s%b\n' "${YELLOW}" "$1" "${NC}"
}

_print_error() {
    printf '%b%s%b\n' "${RED}" "$1" "${NC}"
}

# Detect platform
platform_detect

# Print platform information
_print_header "=== Platform Detection Results ==="
printf '\n'

_print_label "Operating System"
_print_value "${PLATFORM_OS}"

_print_label "Distribution"
_print_value "${PLATFORM_DISTRO}"

_print_label "Architecture"
_print_value "${PLATFORM_ARCH}"

printf '\n'

# Print predicate test results
_print_header "=== Platform Predicates ==="
printf '\n'

_test_predicate() {
    _pred_name="$1"
    _pred_func="$2"
    if "${_pred_func}"; then
        printf '  %b✓%b %s\n' "${GREEN}" "${NC}" "${_pred_name}"
    else
        printf '  %b✗%b %s\n' "${RED}" "${NC}" "${_pred_name}"
    fi
}

_test_predicate "is_linux" "is_linux"
_test_predicate "is_macos" "is_macos"
_test_predicate "is_freebsd" "is_freebsd"
_test_predicate "is_ubuntu" "is_ubuntu"
_test_predicate "is_debian" "is_debian"
_test_predicate "is_arch" "is_arch"
_test_predicate "is_fedora" "is_fedora"
_test_predicate "is_alpine" "is_alpine"
_test_predicate "is_amd64" "is_amd64"
_test_predicate "is_arm64" "is_arm64"
_test_predicate "is_arm" "is_arm"

printf '\n'

# Check package manager availability
_print_header "=== Package Manager Availability ==="
printf '\n'

_check_pkg_mgr() {
    _mgr_name="$1"
    _mgr_cmd="$2"
    if command -v "${_mgr_cmd}" >/dev/null 2>&1; then
        _mgr_path=$(command -v "${_mgr_cmd}")
        printf '  %b✓%b %s: %s\n' "${GREEN}" "${NC}" "${_mgr_name}" "${_mgr_path}"
    else
        printf '  %b✗%b %s: not found\n' "${RED}" "${NC}" "${_mgr_name}"
    fi
}

if is_ubuntu || is_debian; then
    _check_pkg_mgr "apt-get" "apt-get"
    _check_pkg_mgr "dpkg" "dpkg"
elif is_macos; then
    _check_pkg_mgr "brew" "brew"
elif is_arch; then
    _check_pkg_mgr "pacman" "pacman"
elif is_fedora; then
    _check_pkg_mgr "dnf" "dnf"
elif is_alpine; then
    _check_pkg_mgr "apk" "apk"
fi

printf '\n'

# Test install_pkg function (dry-run)
_print_header "=== Package Installation Test (Dry-Run) ==="
printf '\n'

if is_ubuntu || is_debian; then
    _print_warning "Would run: sudo apt-get update && sudo apt-get install -y <packages>"
elif is_macos; then
    _print_warning "Would run: brew install <packages>"
elif is_arch; then
    _print_warning "Would run: sudo pacman -S --noconfirm <packages>"
elif is_fedora; then
    _print_warning "Would run: sudo dnf install -y <packages>"
elif is_alpine; then
    _print_warning "Would run: sudo apk add <packages>"
else
    _print_error "Platform not supported for package installation"
fi

printf '\n'

# Platform support status
_print_header "=== Platform Support Status ==="
printf '\n'

if is_linux || is_macos; then
    _print_value "✓ Platform is supported"
    if is_ubuntu || is_debian || is_macos; then
        _print_value "✓ Package installation is supported"
    else
        _print_warning "⚠ Package installation may not be fully tested"
    fi
else
    _print_error "✗ Platform is not yet supported"
    _print_warning "  Package installation will fail"
fi

printf '\n'
_print_header "=== Debug Complete ==="
