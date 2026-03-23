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
. "${_project_root}/scripts/utils/platform.sh"

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
  # Note: bat, jq, ripgrep, fzf, fd are managed by mise (see configs/tools/mise/conf.d/04-dev-tools.toml)
  _packages="git curl sudo ca-certificates locales zsh tmux python3-pip nasm gcc gcc-multilib libc6-dev cmake wget unzip build-essential htop net-tools tree silversearcher-ag vim rsync postgresql-client imagemagick make pkg-config p7zip-full openssh-client python3-dev python3-venv libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev libncurses-dev autoconf xclip qrencode inotify-tools ffmpeg mpv parallel"

  # Check for ctags and add to list if available
  if pkg_available "exuberant-ctags"; then
    _packages="${_packages} exuberant-ctags"
  elif pkg_available "universal-ctags"; then
    _packages="${_packages} universal-ctags"
  fi

  # Setup Docker repository if Docker packages are needed
  _setup_docker_repo() {
    if ! pkg_installed "docker-ce" && ! pkg_installed "docker.io"; then
      printf '🐳 Setting up Docker repository...\n'
      # Install prerequisites
      sudo apt-get install -y ca-certificates curl gnupg lsb-release >/dev/null 2>&1 || true

      # Add Docker's official GPG key
      if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || {
          printf '⚠️  Failed to add Docker GPG key, skipping Docker installation\n'
          return 1
        }
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
      fi

      # Add Docker repository
      # Get distribution codename (fallback if lsb_release not available)
      if command -v lsb_release >/dev/null 2>&1; then
        _distro_codename=$(lsb_release -cs)
      elif [ -f /etc/os-release ]; then
        _distro_codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2 | tr -d '"')
      else
        printf '⚠️  Cannot determine distribution codename, skipping Docker installation\n'
        return 1
      fi

      _docker_repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${_distro_codename} stable"
      if ! grep -q "download.docker.com" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
        printf '%s\n' "${_docker_repo}" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update >/dev/null 2>&1 || {
          printf '⚠️  Failed to update package list after adding Docker repo\n'
          return 1
        }
      fi
      printf '✅ Docker repository configured\n'
    fi
  }

  # Setup Docker repository before package installation
  _setup_docker_repo || true

  # Add Docker packages if repository was set up successfully
  if [ -f /etc/apt/sources.list.d/docker.list ]; then
    _packages="${_packages} docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
  else
    printf '⚠️  Docker repository not available, skipping Docker packages\n'
    printf '   You can install Docker manually later if needed\n'
  fi

  # Ensure inotify limits are high enough to avoid "Too many open files" errors
  # (VS Code, Slack, tracker-miner-fs, etc. consume many inotify watches)
  if [ ! -f /etc/sysctl.d/99-inotify.conf ] || ! grep -q 'max_user_watches=524288' /etc/sysctl.d/99-inotify.conf 2>/dev/null; then
    printf 'Increasing inotify watch limits (prevents apt watch allocation errors)...\n'
    printf 'fs.inotify.max_user_watches=524288\nfs.inotify.max_user_instances=1024\n' | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
    sudo sysctl --system >/dev/null 2>&1 || true
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
    # shellcheck disable=SC2086 # Intentional word splitting for package list
    sudo apt-get install -y ${_packages_to_install} || {
      printf '⚠️  Some packages failed to install, continuing...\n'
    }
  else
    printf 'All packages are already installed\n'
  fi

  # Ensure locale is configured (needed for clean installs / containers)
  if command -v locale-gen >/dev/null 2>&1; then
    if ! locale -a 2>/dev/null | grep -qi 'en_US.utf8'; then
      printf 'Generating en_US.UTF-8 locale...\n'
      sudo locale-gen en_US.UTF-8 >/dev/null 2>&1 || true
    fi
  fi

elif is_arch; then
  # Arch Linux packages (using pacman)
  # Note: bat, jq, ripgrep, fzf, fd are managed by mise (see configs/tools/mise/conf.d/04-dev-tools.toml)
  _packages="git curl sudo zsh tmux python python-pip nasm gcc cmake wget unzip base-devel htop net-tools tree the_silver_searcher vim rsync postgresql imagemagick make pkgconf p7zip openssh python-virtualenv ctags openssl readline zlib libyaml libffi ncurses autoconf"

  # Update package database
  printf 'Updating package database...\n'
  sudo pacman -Sy || {
    printf '⚠️  Failed to update package database, continuing...\n'
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

  # Install all packages at once
  if [ -n "${_packages_to_install}" ]; then
    printf 'Installing packages: %s\n' "${_packages_to_install}"
    # shellcheck disable=SC2086 # Intentional word splitting for package list
    sudo pacman -S --noconfirm ${_packages_to_install} || {
      printf '⚠️  Some packages failed to install, continuing...\n'
    }
  else
    printf 'All packages are already installed\n'
  fi

elif is_fedora; then
  # Fedora packages (using dnf)
  # Package names differ: python3-devel instead of python3-dev, fd-find, etc.
  # Note: bat, jq, ripgrep, fzf, fd are managed by mise (see configs/tools/mise/conf.d/04-dev-tools.toml)
  _packages="git curl sudo zsh tmux python3 python3-pip nasm gcc gcc-c++ cmake wget unzip htop net-tools tree vim rsync postgresql imagemagick make pkgconf p7zip openssh-clients python3-devel python3-virtualenv openssl-devel readline-devel zlib-devel libyaml-devel libffi-devel ncurses-devel autoconf findutils glibc-langpack-en"

  # Check for ctags
  if pkg_available "ctags"; then
    _packages="${_packages} ctags"
  fi

  # Collect packages that need to be installed
  _packages_to_install=""
  for _package in ${_packages}; do
    if ! pkg_installed "${_package}"; then
      _packages_to_install="${_packages_to_install} ${_package}"
    else
      printf '%s is already installed\n' "${_package}"
    fi
  done

  # Install all packages at once
  if [ -n "${_packages_to_install}" ]; then
    printf 'Installing packages: %s\n' "${_packages_to_install}"
    # shellcheck disable=SC2086 # Intentional word splitting for package list
    sudo dnf install -y ${_packages_to_install} || {
      printf '⚠️  Some packages failed to install, continuing...\n'
    }
  else
    printf 'All packages are already installed\n'
  fi

elif is_alpine; then
  # Alpine Linux packages (using apk)
  # Note: bat, jq, ripgrep, fzf, fd are managed by mise (see configs/tools/mise/conf.d/04-dev-tools.toml)
  _packages="git curl sudo zsh tmux python3 py3-pip nasm gcc musl-dev cmake wget unzip build-base htop net-tools tree the_silver_searcher vim rsync postgresql-client imagemagick make pkgconf p7zip openssh-client python3-dev openssl-dev readline-dev zlib-dev yaml-dev libffi-dev ncurses-dev autoconf ctags xclip qrencode inotify-tools ffmpeg parallel"

  # Update package index
  printf 'Updating package index...\n'
  sudo apk update || {
    printf '⚠️  Failed to update package index, continuing...\n'
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

  # Install all packages at once
  if [ -n "${_packages_to_install}" ]; then
    printf 'Installing packages: %s\n' "${_packages_to_install}"
    # shellcheck disable=SC2086 # Intentional word splitting for package list
    sudo apk add ${_packages_to_install} || {
      printf '⚠️  Some packages failed to install, continuing...\n'
    }
  else
    printf 'All packages are already installed\n'
  fi

elif is_macos; then
  # macOS packages (using Homebrew)
  # Note: bat, jq, ripgrep, fzf, fd are managed by mise (see configs/tools/mise/conf.d/04-dev-tools.toml)
  _packages="zsh tmux python@3 pipx nasm gcc cmake git curl wget unzip htop tree neovim"

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
  printf '⚠️  Package installation not yet supported for this platform\n'
  printf 'Platform: OS=%s, Distro=%s\n' "${PLATFORM_OS}" "${PLATFORM_DISTRO}"
  printf 'Please install required packages manually.\n'
fi

printf '✅ Package installation complete!\n'
