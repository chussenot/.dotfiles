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
