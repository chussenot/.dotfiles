#!/bin/sh

# Improved Dotfiles Installation Script
# Multi-platform POSIX-compliant version

set -eu

# Get the directory where this script is located (POSIX-compatible)
get_script_dir() {
    # POSIX-compatible way to get script directory
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

SCRIPT_DIR=$(get_script_dir)

# Source platform detection module
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/platform.sh"

# Detect platform early
platform_detect

# Colors for output (using printf for POSIX compatibility)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    printf '%b[INFO]%b %s\n' "${BLUE}" "${NC}" "$1"
}

print_success() {
    printf '%b[SUCCESS]%b %s\n' "${GREEN}" "${NC}" "$1"
}

print_warning() {
    printf '%b[WARNING]%b %s\n' "${YELLOW}" "${NC}" "$1"
}

print_error() {
    printf '%b[ERROR]%b %s\n' "${RED}" "${NC}" "$1"
}

# Check if running as root (POSIX-compatible)
if [ "$(id -u)" -eq 0 ]; then
    print_error "This script should not be run as root"
    exit 1
fi

print_status "🚀 Starting dotfiles installation..."
print_status "Platform: OS=${PLATFORM_OS}, Distro=${PLATFORM_DISTRO}, Arch=${PLATFORM_ARCH}"

# Check if we're in the right directory
if [ ! -f "${SCRIPT_DIR}/README.md" ]; then
    print_error "Please run this script from the dotfiles directory"
    exit 1
fi

# Check platform support
if [ "${PLATFORM_OS}" = "unknown" ]; then
    print_warning "Unknown platform detected. Some features may not work."
    print_warning "Supported platforms: Linux (Ubuntu/Debian), macOS"
fi

# Create backup before proceeding
print_status "💾 Creating backup of existing dotfiles..."
"${SCRIPT_DIR}/scripts/utils/backup.sh" || {
    print_warning "Backup script encountered an error, continuing anyway..."
}

# Install system packages (platform-specific)
print_status "📦 Installing system packages..."
if is_linux || is_macos; then
    "${SCRIPT_DIR}/scripts/install/install-packages.sh" || {
        print_warning "Package installation encountered an error, continuing anyway..."
    }
else
    print_warning "Package installation not supported on this platform"
    print_warning "Please install required packages manually"
fi

# Install Oh My Zsh if not already installed
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    print_status "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        print_warning "Oh My Zsh installation encountered an error"
    }
    print_success "Oh My Zsh installed"
else
    print_warning "Oh My Zsh already installed"
fi

# Install Zinit Plugin Manager
print_status "🔌 Installing Zinit Plugin Manager..."
if [ ! -d "${HOME}/.local/share/zinit/zinit.git" ]; then
    mkdir -p "${HOME}/.local/share/zinit" && chmod g-rwX "${HOME}/.local/share/zinit" || true
    if command -v git >/dev/null 2>&1; then
        git clone --depth=1 https://github.com/zdharma-continuum/zinit "${HOME}/.local/share/zinit/zinit.git" || {
            print_error "Failed to clone Zinit"
            exit 1
        }
        print_success "Zinit Plugin Manager installed"
    else
        print_error "git is required to install Zinit"
        exit 1
    fi
else
    print_warning "Zinit Plugin Manager already installed"
fi

# Setup symlinks
print_status "🔗 Setting up symlinks..."
"${SCRIPT_DIR}/scripts/setup/setup-symlinks.sh" || {
    print_warning "Symlink setup encountered an error, continuing anyway..."
}

# Install mise if not present
print_status "🛠️ Installing mise (tool version manager)..."
if ! command -v mise >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
        curl https://mise.run | sh || {
            print_error "Failed to install mise"
            exit 1
        }
        # Add mise to PATH for current session
        export PATH="${HOME}/.local/bin:${PATH}"
        print_success "mise installed"
    else
        print_error "curl is required to install mise"
        exit 1
    fi
else
    print_warning "mise already installed"
fi

# Install tools with mise
print_status "🛠️ Installing development tools..."
if command -v mise >/dev/null 2>&1; then
    cd "${SCRIPT_DIR}"
    mise install || {
        print_warning "mise install encountered an error, continuing anyway..."
    }
    print_success "Development tools installed"
else
    print_warning "mise not found, skipping tool installation"
fi

# Install Neovim plugins
print_status "📝 Installing Neovim plugins..."
if command -v nvim >/dev/null 2>&1; then
    nvim +PlugInstall +qall || {
        print_warning "Neovim plugin installation encountered an error, continuing anyway..."
    }
    print_success "Neovim plugins installed"
else
    print_warning "Neovim not found, skipping plugin installation"
fi

print_success "✅ Installation complete!"
printf '\n'
print_status "📋 Post-installation steps:"
printf '1. Restart your terminal or run: source ~/.zshrc\n'
printf '2. Customize your local settings in: %s/local/\n' "${SCRIPT_DIR}"
printf '3. Install any additional tools you need\n'
printf '\n'
print_status "🎉 Your development environment is ready!"

# Install chussenot zsh theme
print_status "🎨 Installing chussenot zsh theme..."
"${SCRIPT_DIR}/scripts/setup/install-theme.sh" || {
    print_warning "Theme installation encountered an error, continuing anyway..."
}

# install the man page
print_status "📖 Installing man page..."
"${SCRIPT_DIR}/scripts/setup/install-man-page.sh" || {
    print_warning "Man page installation encountered an error, continuing anyway..."
}
