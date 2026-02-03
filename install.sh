#!/bin/sh

# Improved Dotfiles Installation Script
# Multi-platform POSIX-compliant version
# Defensive against non-interactive shells, missing tools, and non-Ubuntu distros

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
if [ -f "${SCRIPT_DIR}/scripts/utils/platform.sh" ]; then
    . "${SCRIPT_DIR}/scripts/utils/platform.sh"
else
    printf 'Error: platform.sh not found\n' >&2
    exit 1
fi

# Detect platform early
platform_detect

# Colors for output (using printf for POSIX compatibility)
# Only use colors if output is to a terminal
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    # Non-interactive/non-terminal: no colors
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

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

# Check if running in interactive shell
# POSIX-compliant check: test if stdin is a terminal
is_interactive() {
    [ -t 0 ]
}

# Check for required tools
check_required_tool() {
    _tool="$1"
    _required="${2:-false}"  # Optional second arg: true if tool is required
    if ! command -v "${_tool}" >/dev/null 2>&1; then
        if [ "${_required}" = "true" ]; then
            print_error "${_tool} is required but not found. Please install it first."
            return 1
        else
            print_warning "${_tool} not found. Some features may not work."
            return 1
        fi
    fi
    return 0
}

# Check for optional tools (warn but continue)
check_optional_tool() {
    _tool="$1"
    if ! command -v "${_tool}" >/dev/null 2>&1; then
        print_warning "${_tool} not found. Some features may not work."
        return 1
    fi
    return 0
}

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
    print_warning "Supported platforms: Linux (Ubuntu/Debian/Arch/Fedora/Alpine), macOS"
fi

# Check for required tools upfront
print_status "🔍 Checking for required tools..."
_missing_required=false

# git is required for Antidote installation
if ! check_required_tool git true; then
    _missing_required=true
fi

# curl is required for mise installation
if ! check_required_tool curl true; then
    _missing_required=true
fi

# sudo is required for package installation on most Linux distros
# Check if we need sudo (only if we're on Linux and not root)
if is_linux; then
    if ! check_required_tool sudo false; then
        # If sudo is missing, check if we can install packages without it
        # (e.g., if user has direct root access or package manager doesn't need sudo)
        if [ "${PLATFORM_DISTRO}" != "unknown" ]; then
            print_warning "sudo not found. Package installation may fail."
            print_warning "You may need to install packages manually or run package installation as root."
        fi
    fi
fi

# Exit if required tools are missing
if [ "${_missing_required}" = "true" ]; then
    print_error "Required tools are missing. Please install them and try again."
    exit 1
fi

# Check for optional but recommended tools
check_optional_tool zsh
check_optional_tool nvim

# Create backup before proceeding
print_status "💾 Creating backup of existing dotfiles..."
if [ -f "${SCRIPT_DIR}/scripts/utils/backup.sh" ]; then
    "${SCRIPT_DIR}/scripts/utils/backup.sh" || {
        print_warning "Backup script encountered an error, continuing anyway..."
    }
else
    print_warning "Backup script not found, skipping backup"
fi

# Install system packages (platform-specific)
print_status "📦 Installing system packages..."
if is_linux || is_macos; then
    if [ -f "${SCRIPT_DIR}/scripts/install/install-packages.sh" ]; then
        # Check if we need sudo for package installation
        if is_linux && ! command -v sudo >/dev/null 2>&1; then
            print_warning "sudo not found. Skipping package installation."
            print_warning "Please install required packages manually."
        else
            "${SCRIPT_DIR}/scripts/install/install-packages.sh" || {
                print_warning "Package installation encountered an error, continuing anyway..."
            }
        fi
    else
        print_warning "Package installation script not found"
        print_warning "Please install required packages manually"
    fi
else
    print_warning "Package installation not supported on this platform"
    print_warning "Please install required packages manually"
fi

# Install Antidote Plugin Manager
print_status "🔌 Installing Antidote Plugin Manager..."
if [ ! -d "${HOME}/.antidote" ]; then
    if command -v git >/dev/null 2>&1; then
        # Use git clone with proper error handling
        if git clone --depth=1 https://github.com/mattmc3/antidote.git "${HOME}/.antidote" 2>/dev/null; then
            print_success "Antidote Plugin Manager installed"
        else
            print_error "Failed to clone Antidote"
            print_error "Check your internet connection and try again"
            exit 1
        fi
    else
        print_error "git is required to install Antidote but was not found"
        exit 1
    fi
else
    print_warning "Antidote Plugin Manager already installed"
fi

# Setup symlinks
print_status "🔗 Setting up symlinks..."
if [ -f "${SCRIPT_DIR}/scripts/setup/setup-symlinks.sh" ]; then
    "${SCRIPT_DIR}/scripts/setup/setup-symlinks.sh" || {
        print_warning "Symlink setup encountered an error, continuing anyway..."
    }
else
    print_warning "Symlink setup script not found, skipping symlink creation"
fi

# Install mise if not present
print_status "🛠️ Installing mise (tool version manager)..."
if ! command -v mise >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
        # Check if we can reach the mise installation URL
        if curl -fsSL https://mise.run >/dev/null 2>&1; then
            # Install mise (suppress progress for non-interactive shells)
            if is_interactive; then
                curl https://mise.run | sh || {
                    print_error "Failed to install mise"
                    exit 1
                }
            else
                curl -fsSL https://mise.run | sh || {
                    print_error "Failed to install mise"
                    exit 1
                }
            fi
            # Add mise to PATH for current session
            export PATH="${HOME}/.local/bin:${PATH}"
            print_success "mise installed"
        else
            print_error "Cannot reach mise installation server"
            print_error "Check your internet connection and try again"
            exit 1
        fi
    else
        print_error "curl is required to install mise but was not found"
        exit 1
    fi
else
    print_warning "mise already installed"
fi

# Install tools with mise
print_status "🛠️ Installing development tools..."
if command -v mise >/dev/null 2>&1; then
    if [ -d "${SCRIPT_DIR}" ]; then
        cd "${SCRIPT_DIR}" || {
            print_warning "Cannot change to script directory, skipping mise tool installation"
        }
        # Trust mise config files to avoid trust prompts (only if files exist)
        if [ -f "${SCRIPT_DIR}/mise.toml" ]; then
            mise trust "${SCRIPT_DIR}/mise.toml" 2>/dev/null || true
        fi
        if [ -f "${HOME}/.config/mise/config.toml" ]; then
            mise trust "${HOME}/.config/mise/config.toml" 2>/dev/null || true
        fi
        # Only run mise install if we're in the right directory
        if [ -f "${SCRIPT_DIR}/mise.toml" ] || [ -f "${SCRIPT_DIR}/.mise.toml" ]; then
            mise install || {
                print_warning "mise install encountered an error, continuing anyway..."
            }
            print_success "Development tools installed"
        else
            print_warning "No mise.toml found, skipping tool installation"
        fi
    else
        print_warning "Script directory not accessible, skipping mise tool installation"
    fi
else
    print_warning "mise not found, skipping tool installation"
fi

# Install Neovim plugins
print_status "📝 Installing Neovim plugins..."
if command -v nvim >/dev/null 2>&1; then
    # Check if nvim can run in headless mode (for non-interactive shells)
    if is_interactive; then
        nvim +PlugInstall +qall 2>/dev/null || {
            print_warning "Neovim plugin installation encountered an error, continuing anyway..."
        }
    else
        # Non-interactive: use headless mode explicitly
        nvim --headless +PlugInstall +qall 2>/dev/null || {
            print_warning "Neovim plugin installation encountered an error, continuing anyway..."
        }
    fi
    print_success "Neovim plugins installed"
else
    print_warning "Neovim not found, skipping plugin installation"
fi

# Install chussenot zsh theme
print_status "🎨 Installing chussenot zsh theme..."
if [ -f "${SCRIPT_DIR}/scripts/setup/install-theme.sh" ]; then
    "${SCRIPT_DIR}/scripts/setup/install-theme.sh" || {
        print_warning "Theme installation encountered an error, continuing anyway..."
    }
else
    print_warning "Theme installation script not found, skipping theme installation"
fi

# Install the man page
print_status "📖 Installing man page..."
if [ -f "${SCRIPT_DIR}/scripts/setup/install-man-page.sh" ]; then
    "${SCRIPT_DIR}/scripts/setup/install-man-page.sh" || {
        print_warning "Man page installation encountered an error, continuing anyway..."
    }
else
    print_warning "Man page installation script not found, skipping man page installation"
fi

# Run update function to refresh all installed tools and plugins
# Only run if we're in an interactive shell (update function may require interaction)
if is_interactive; then
    print_status "🔄 Running update function to refresh installed tools..."
    if command -v zsh >/dev/null 2>&1 && [ -f "${HOME}/.zshrc" ]; then
        zsh -c 'source ~/.zshrc 2>/dev/null; update' 2>/dev/null || {
            print_warning "Update function encountered an error, continuing anyway..."
        }
        print_success "Update function completed"
    else
        print_warning "zsh or .zshrc not found, skipping update function"
    fi
else
    print_warning "Non-interactive shell detected, skipping update function"
    print_warning "Run 'update' manually after installation completes"
fi

print_success "✅ Installation complete!"
printf '\n'
print_status "📋 Post-installation steps:"
printf '1. Restart your terminal or run: source ~/.zshrc\n'
printf '2. Customize your local settings in: %s/local/\n' "${SCRIPT_DIR}"
printf '3. Install any additional tools you need\n'
printf '\n'
print_status "🎉 Your development environment is ready!"
