#!/bin/sh

# Package installation script
# Multi-platform POSIX-compliant version

set -eu

# Get script directory to find lib directory
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

# Detect platform
platform_detect

printf '📦 Installing system packages...\n'
printf 'Platform: OS=%s, Distro=%s, Arch=%s\n' \
    "${PLATFORM_OS}" "${PLATFORM_DISTRO}" "${PLATFORM_ARCH}"

# Check if platform is supported
if [ "${PLATFORM_OS}" = "unknown" ] || [ "${PLATFORM_DISTRO}" = "unknown" ]; then
    printf '⚠️  Warning: Unknown platform detected\n'
    printf 'Package installation may not work correctly.\n'
fi

# Platform-specific package lists
if is_ubuntu || is_debian; then
    _packages="zsh tmux python3-pip jq nasm gcc gcc-multilib libc6-dev cmake git curl wget unzip build-essential fzf bat htop net-tools tree ripgrep fd-find"

    # Check for ctags and add to list if available
    if pkg_available "exuberant-ctags"; then
        _packages="${_packages} exuberant-ctags"
    elif pkg_available "universal-ctags"; then
        _packages="${_packages} universal-ctags"
    fi

    # Update package list once (more efficient than updating per package)
    printf 'Updating package list...\n'
    sudo apt-get update || {
        printf '⚠️  Failed to update package list, continuing...\n'
    }

    # Collect packages that need to be installed
    _packages_to_install=""
    for _package in ${_packages}; do
        if ! pkg_installed "${_package}"; then
            _packages_to_install="${_packages_to_install} ${_package}"
        else
            printf '%s is already installed\n' "${_package}"
        fi
    done

    # Install all packages at once (much more efficient)
    if [ -n "${_packages_to_install}" ]; then
        printf 'Installing packages: %s\n' "${_packages_to_install}"
        # Install directly to avoid install_pkg calling apt-get update again
        sudo apt-get install -y ${_packages_to_install} || {
            printf '⚠️  Some packages failed to install, continuing...\n'
        }
    else
        printf 'All packages are already installed\n'
    fi

elif is_macos; then
    # macOS packages (using Homebrew)
    _packages="zsh tmux python@3 pipx jq nasm gcc cmake git curl wget unzip fzf bat htop tree ripgrep fd"

    # Install packages
    for _package in ${_packages}; do
        if ! pkg_installed "${_package}"; then
            printf 'Installing %s...\n' "${_package}"
            install_pkg "${_package}" || {
                printf '⚠️  Failed to install %s, continuing...\n' "${_package}"
            }
        else
            printf '%s is already installed\n' "${_package}"
        fi
    done

else
    printf '❌ Package installation not yet supported for this platform\n'
    printf 'Platform: OS=%s, Distro=%s\n' "${PLATFORM_OS}" "${PLATFORM_DISTRO}"
    printf 'Please install required packages manually.\n'
    exit 1
fi

# Install fzf shell integration if fzf is installed
if command -v fzf >/dev/null 2>&1; then
    printf '🔧 Setting up fzf shell integration...\n'

    # Check if fzf shell integration is already set up
    if [ ! -f "${HOME}/.fzf.zsh" ]; then
        # Install fzf shell integration
        if [ -f "${HOME}/.fzf/install" ]; then
            # Use existing fzf installation
            "${HOME}/.fzf/install" --all --no-bash --no-fish
        else
            # Install fzf from scratch
            if command -v git >/dev/null 2>&1; then
                git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
                "${HOME}/.fzf/install" --all --no-bash --no-fish
            else
                printf '⚠️  git not found, cannot install fzf\n'
            fi
        fi
        printf '✅ fzf shell integration installed\n'
    else
        printf '✅ fzf shell integration already configured\n'
    fi
else
    printf '⚠️  fzf not found, skipping shell integration setup\n'
fi

printf '✅ Package installation complete!\n'
