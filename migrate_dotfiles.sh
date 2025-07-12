#!/bin/bash

# Dotfiles Migration Script
# This script will reorganize your dotfiles according to the new structure

set -e

echo "🚀 Starting dotfiles migration..."

# Create new directory structure
echo "📁 Creating new directory structure..."

mkdir -p scripts/{install,setup,utils}
mkdir -p configs/{shell/{zsh,bash},terminal/{tmux,alacritty},editor/{nvim,vscode},tools/{git,mise,fzf},system/{systemd,udev}}
mkdir -p local/{zsh,git}
mkdir -p themes/{zsh,tmux}
mkdir -p plugins/{zsh,nvim}
mkdir -p docs/components

# Move existing files to new structure
echo "📦 Moving existing files..."

# Move tmux files
if [ -d "dotfiles/tmux" ]; then
    cp -r dotfiles/tmux/* configs/terminal/tmux/
    echo "✅ Moved tmux configs"
fi

# Move zsh files
if [ -d "dotfiles/zsh" ]; then
    cp -r dotfiles/zsh/* configs/shell/zsh/
    echo "✅ Moved zsh configs"
fi

# Move nvim files
if [ -d "dotfiles/nvim" ]; then
    cp -r dotfiles/nvim/* configs/editor/nvim/
    echo "✅ Moved nvim configs"
fi

# Move mise files
if [ -d "dotfiles/mise" ]; then
    cp -r dotfiles/mise/* configs/tools/mise/
    echo "✅ Moved mise configs"
fi

# Move tmux controller
if [ -f "tmux_controller.py" ]; then
    cp tmux_controller.py configs/terminal/tmux/scripts/
    echo "✅ Moved tmux controller"
fi

# Move z.sh
if [ -f "dotfiles/z.sh" ]; then
    cp dotfiles/z.sh configs/shell/zsh/
    echo "✅ Moved z.sh"
fi

# Create improved installation script
echo "🔧 Creating improved installation script..."

cat > scripts/install/install-packages.sh << 'EOF'
#!/bin/bash

# Package installation script
set -e

echo "📦 Installing system packages..."

packages=(
    zsh
    tmux
    python3-pip
    jq
    nasm
    gcc
    gcc-multilib
    libc6-dev
    cmake
    git
    curl
    wget
    unzip
    build-essential
)

# Check for ctags
if apt-cache show exuberant-ctags >/dev/null 2>&1; then
    packages+=(exuberant-ctags)
elif apt-cache show universal-ctags >/dev/null 2>&1; then
    packages+=(universal-ctags)
fi

for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "Installing $package..."
        sudo apt-get update
        sudo apt-get install -y "$package"
    else
        echo "$package is already installed"
    fi
done

echo "✅ Package installation complete!"
EOF

# Create symlink setup script
cat > scripts/setup/setup-symlinks.sh << 'EOF'
#!/bin/bash

# Symlink setup script
set -e

echo "🔗 Setting up symlinks..."

DOTFILES_DIR="$HOME/.dotfiles"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        mv "$target" "$target.backup"
    fi
    
    ln -s "$source" "$target"
    echo "✅ Linked $target"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/configs/terminal/tmux/tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/configs/editor/nvim" "$HOME/.config/nvim"
create_symlink "$DOTFILES_DIR/configs/tools/mise/tool-versions" "$HOME/.tool-versions"
create_symlink "$DOTFILES_DIR/configs/shell/zsh/z.sh" "$HOME/z.sh"

# Create local directories if they don't exist
mkdir -p "$HOME/.local/share/zsh"
mkdir -p "$HOME/.local/share/nvim"

echo "✅ Symlink setup complete!"
EOF

# Create backup script
cat > scripts/utils/backup.sh << 'EOF'
#!/bin/bash

# Backup script for dotfiles
set -e

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Creating backup in $BACKUP_DIR"

# Backup existing dotfiles
files_to_backup=(
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.config/nvim"
    "$HOME/.tool-versions"
    "$HOME/z.sh"
)

for file in "${files_to_backup[@]}"; do
    if [ -e "$file" ]; then
        cp -r "$file" "$BACKUP_DIR/"
        echo "✅ Backed up $file"
    fi
done

echo "✅ Backup complete!"
EOF

# Create documentation
echo "📚 Creating documentation..."

cat > docs/INSTALLATION.md << 'EOF'
# Installation Guide

## Quick Install

```bash
git clone https://github.com/chussenot/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Manual Installation

1. Install system packages:
   ```bash
   ./scripts/install/install-packages.sh
   ```

2. Setup symlinks:
   ```bash
   ./scripts/setup/setup-symlinks.sh
   ```

3. Install Oh My Zsh:
   ```bash
   ./scripts/install/install-oh-my-zsh.sh
   ```

4. Install tools:
   ```bash
   ./scripts/install/install-tools.sh
   ```

## Post-Installation

1. Restart your terminal
2. Install Neovim plugins: `nvim +PlugInstall +qall`
3. Customize local settings in `local/` directory
EOF

# Make scripts executable
chmod +x scripts/install/*.sh
chmod +x scripts/setup/*.sh
chmod +x scripts/utils/*.sh

echo "✅ Migration complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review the new structure in ORGANIZATION_PLAN.md"
echo "2. Test the installation: ./scripts/setup/setup-symlinks.sh"
echo "3. Update your main install.sh to use the new structure"
echo "4. Commit the changes to git"
echo ""
echo "🎉 Your dotfiles are now better organized!" 