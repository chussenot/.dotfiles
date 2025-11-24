#!/bin/sh

# Platform Detection Module
# POSIX-compliant platform detection for multi-platform dotfiles installer
#
# This module provides:
# - Platform detection (OS, distribution, architecture)
# - Helper predicates (is_linux, is_macos, is_ubuntu, etc.)
# - Generic package installation wrapper (install_pkg)

# Platform variables (set by platform_detect)
PLATFORM_OS="unknown"
PLATFORM_DISTRO="unknown"
PLATFORM_ARCH="unknown"

# Detect platform OS, distribution, and architecture
platform_detect() {
    # Detect OS using uname -s
    _os=$(uname -s)
    case "${_os}" in
        Linux)
            PLATFORM_OS="linux"
            ;;
        Darwin)
            PLATFORM_OS="darwin"
            ;;
        FreeBSD)
            PLATFORM_OS="freebsd"
            ;;
        OpenBSD)
            PLATFORM_OS="openbsd"
            ;;
        *)
            PLATFORM_OS="unknown"
            ;;
    esac

    # Detect architecture using uname -m
    _arch=$(uname -m)
    case "${_arch}" in
        x86_64|amd64)
            PLATFORM_ARCH="amd64"
            ;;
        aarch64|arm64)
            PLATFORM_ARCH="arm64"
            ;;
        armv7l|armv6l|arm)
            PLATFORM_ARCH="arm"
            ;;
        *)
            PLATFORM_ARCH="unknown"
            ;;
    esac

    # Detect distribution (Linux only)
    if [ "${PLATFORM_OS}" = "linux" ]; then
        if [ -f /etc/os-release ]; then
            # Parse /etc/os-release using POSIX-compliant methods
            # Extract ID field (e.g., ID=ubuntu, ID=debian)
            _distro_id=$(sed -n 's/^ID=\(.*\)$/\1/p' /etc/os-release | head -n 1)
            # Remove quotes if present
            _distro_id=$(printf '%s\n' "${_distro_id}" | sed "s/^[\"']//;s/[\"']$//")
            case "${_distro_id}" in
                ubuntu)
                    PLATFORM_DISTRO="ubuntu"
                    ;;
                debian)
                    PLATFORM_DISTRO="debian"
                    ;;
                arch|archlinux)
                    PLATFORM_DISTRO="arch"
                    ;;
                fedora)
                    PLATFORM_DISTRO="fedora"
                    ;;
                centos|rhel)
                    PLATFORM_DISTRO="centos"
                    ;;
                alpine)
                    PLATFORM_DISTRO="alpine"
                    ;;
                *)
                    PLATFORM_DISTRO="unknown"
                    ;;
            esac
        else
            PLATFORM_DISTRO="unknown"
        fi
    elif [ "${PLATFORM_OS}" = "darwin" ]; then
        # macOS doesn't have a traditional distro, but we can detect version
        PLATFORM_DISTRO="macos"
    else
        PLATFORM_DISTRO="unknown"
    fi
}

# Platform predicate functions
is_linux() {
    [ "${PLATFORM_OS}" = "linux" ]
}

is_macos() {
    [ "${PLATFORM_OS}" = "darwin" ]
}

is_freebsd() {
    [ "${PLATFORM_OS}" = "freebsd" ]
}

is_ubuntu() {
    [ "${PLATFORM_DISTRO}" = "ubuntu" ]
}

is_debian() {
    [ "${PLATFORM_DISTRO}" = "debian" ]
}

is_arch() {
    [ "${PLATFORM_DISTRO}" = "arch" ]
}

is_fedora() {
    [ "${PLATFORM_DISTRO}" = "fedora" ]
}

is_alpine() {
    [ "${PLATFORM_DISTRO}" = "alpine" ]
}

is_amd64() {
    [ "${PLATFORM_ARCH}" = "amd64" ]
}

is_arm64() {
    [ "${PLATFORM_ARCH}" = "arm64" ]
}

is_arm() {
    [ "${PLATFORM_ARCH}" = "arm" ] || [ "${PLATFORM_ARCH}" = "arm64" ]
}

# Generic package installation wrapper
# Usage: install_pkg package1 package2 ...
install_pkg() {
    if [ $# -eq 0 ]; then
        printf 'Error: install_pkg requires at least one package name\n' >&2
        return 1
    fi

    if is_ubuntu || is_debian; then
        # Ubuntu/Debian: use apt-get
        if ! command -v apt-get >/dev/null 2>&1; then
            printf 'Error: apt-get not found. Cannot install packages.\n' >&2
            return 1
        fi
        sudo apt-get update || return 1
        sudo apt-get install -y "$@" || return 1
    elif is_macos; then
        # macOS: use Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            printf 'Error: Homebrew not found. Please install Homebrew first.\n' >&2
            printf 'Visit: https://brew.sh\n' >&2
            return 1
        fi
        brew install "$@" || return 1
    elif is_arch; then
        # Arch Linux: use pacman
        if ! command -v pacman >/dev/null 2>&1; then
            printf 'Error: pacman not found. Cannot install packages.\n' >&2
            return 1
        fi
        sudo pacman -S --noconfirm "$@" || return 1
    elif is_fedora; then
        # Fedora: use dnf
        if ! command -v dnf >/dev/null 2>&1; then
            printf 'Error: dnf not found. Cannot install packages.\n' >&2
            return 1
        fi
        sudo dnf install -y "$@" || return 1
    elif is_alpine; then
        # Alpine: use apk
        if ! command -v apk >/dev/null 2>&1; then
            printf 'Error: apk not found. Cannot install packages.\n' >&2
            return 1
        fi
        sudo apk add "$@" || return 1
    else
        printf 'Error: Unsupported platform (OS: %s, Distro: %s)\n' \
            "${PLATFORM_OS}" "${PLATFORM_DISTRO}" >&2
        printf 'Package installation is not supported on this platform.\n' >&2
        return 1
    fi
}

# Check if a package is installed (platform-specific)
# Usage: pkg_installed package_name
pkg_installed() {
    if [ $# -ne 1 ]; then
        printf 'Error: pkg_installed requires exactly one package name\n' >&2
        return 1
    fi

    _pkg_name="$1"

    if is_ubuntu || is_debian; then
        dpkg -s "${_pkg_name}" >/dev/null 2>&1
    elif is_macos; then
        brew list "${_pkg_name}" >/dev/null 2>&1
    elif is_arch; then
        pacman -Q "${_pkg_name}" >/dev/null 2>&1
    elif is_fedora; then
        rpm -q "${_pkg_name}" >/dev/null 2>&1
    elif is_alpine; then
        apk info -e "${_pkg_name}" >/dev/null 2>&1
    else
        # Unknown platform: assume not installed
        return 1
    fi
}

# Check if a package is available in repositories (platform-specific)
# Usage: pkg_available package_name
pkg_available() {
    if [ $# -ne 1 ]; then
        printf 'Error: pkg_available requires exactly one package name\n' >&2
        return 1
    fi

    _pkg_name="$1"

    if is_ubuntu || is_debian; then
        apt-cache show "${_pkg_name}" >/dev/null 2>&1
    elif is_macos; then
        brew search "${_pkg_name}" >/dev/null 2>&1
    elif is_arch; then
        pacman -Ss "${_pkg_name}" >/dev/null 2>&1
    elif is_fedora; then
        dnf search "${_pkg_name}" >/dev/null 2>&1
    elif is_alpine; then
        apk search "${_pkg_name}" >/dev/null 2>&1
    else
        # Unknown platform: assume not available
        return 1
    fi
}
