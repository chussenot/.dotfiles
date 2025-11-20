#!/bin/bash

# Improved Dotfiles Installation Script
# This script uses the new organized structure

set -Eeuo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to handle errors
handle_error() {
    print_error "Error on line $1: command exited with status $2"
    exit 1
}

# Set error trap
trap 'handle_error $LINENO $?' ERR

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "🚀 Starting dotfiles installation..."

# Check if we're in the right directory
if [[ ! -f "$SCRIPT_DIR/README.md" ]]; then
    print_error "Please run this script from the dotfiles directory"
    exit 1
fi

# Create backup before proceeding
print_status "💾 Creating backup of existing dotfiles..."
"$SCRIPT_DIR/scripts/utils/backup.sh"

# Install system packages
print_status "📦 Installing system packages..."
"$SCRIPT_DIR/scripts/install/install-packages.sh"

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_status "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_warning "Oh My Zsh already installed"
fi

# Install Zinit Plugin Manager
print_status "🔌 Installing Zinit Plugin Manager..."
if [[ ! -d "$HOME/.local/share/zinit/zinit.git" ]]; then
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone --depth=1 https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
    print_success "Zinit Plugin Manager installed"
else
    print_warning "Zinit Plugin Manager already installed"
fi
# Setup symlinks
print_status "🔗 Setting up symlinks..."
"$SCRIPT_DIR/scripts/setup/setup-symlinks.sh"

# Install mise if not present
print_status "🛠️ Installing mise (tool version manager)..."
if ! command -v mise &> /dev/null; then
    curl https://mise.run | sh
    # Add mise to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    print_success "mise installed"
else
    print_warning "mise already installed"
fi

# Install tools with mise
print_status "🛠️ Installing development tools..."
if command -v mise &> /dev/null; then
    cd "$SCRIPT_DIR"
    mise install
    print_success "Development tools installed"
else
    print_warning "mise not found, skipping tool installation"
fi

# Install Neovim plugins
print_status "📝 Installing Neovim plugins..."
if command -v nvim &> /dev/null; then
    nvim +PlugInstall +qall
    print_success "Neovim plugins installed"
else
    print_warning "Neovim not found, skipping plugin installation"
fi

print_success "✅ Installation complete!"
echo ""
print_status "📋 Post-installation steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Customize your local settings in: $SCRIPT_DIR/local/"
echo "3. Install any additional tools you need"
echo ""
print_status "🎉 Your development environment is ready!"

# Install chussenot zsh theme
print_status "🎨 Installing chussenot zsh theme..."
"$SCRIPT_DIR/scripts/setup/install-theme.sh"

# install the man page
print_status "📖 Installing man page..."
"$SCRIPT_DIR/scripts/setup/install-man-page.sh"
