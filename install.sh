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

# Setup symlinks
print_status "🔗 Setting up symlinks..."
"$SCRIPT_DIR/scripts/setup/setup-symlinks.sh"

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

# Create local configuration directory
print_status "📁 Setting up local configuration..."
mkdir -p "$SCRIPT_DIR/local"

# Create example local zsh config
if [[ ! -f "$SCRIPT_DIR/local/zsh/local.zsh" ]]; then
    cat > "$SCRIPT_DIR/local/zsh/local.zsh" << 'EOF'
# Local zsh configuration
# This file is for machine-specific settings
# It will be sourced automatically by the main zshrc

# Example local aliases
# alias myalias='mycommand'

# Example local environment variables
# export MY_VAR="value"

# Example local functions
# myfunction() {
#     echo "This is a local function"
# }
EOF
    print_success "Created local zsh configuration template"
fi

# Create .gitignore for local directory
cat > "$SCRIPT_DIR/local/.gitignore" << 'EOF'
# Local configuration files
# These files contain machine-specific settings and should not be committed
*
!.gitignore
EOF

print_success "✅ Installation complete!"
echo ""
print_status "📋 Post-installation steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Customize your local settings in: $SCRIPT_DIR/local/"
echo "3. Install any additional tools you need"
echo ""
print_status "🎉 Your development environment is ready!" 