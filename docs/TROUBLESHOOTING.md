# Troubleshooting Guide

This guide covers common issues and their solutions when installing or using these dotfiles.

## Installation Issues

### Permission Denied

**Symptom**: `./install.sh: Permission denied`

**Solution**:

```sh
chmod +x install.sh
chmod +x scripts/**/*.sh
```

### Git Not Found

**Symptom**: `Error: git is required but not found`

**Solution**:

```sh
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y git

# macOS (installs Xcode Command Line Tools)
xcode-select --install

# Fedora
sudo dnf install git

# Arch
sudo pacman -S git
```

### Curl Not Found

**Symptom**: `Error: curl is required but not found`

**Solution**:

```sh
# Ubuntu/Debian
sudo apt-get install -y curl

# macOS (should be pre-installed)
# If missing, install via Homebrew:
brew install curl

# Fedora
sudo dnf install curl
```

### Sudo Not Found or Permission Issues

**Symptom**: `sudo: command not found` or `sudo: permission denied`

**Solution**:

1. If sudo is not installed:

```sh
# As root user
apt-get install sudo
```

1. If your user is not in the sudo group:

```sh
# As root user
usermod -aG sudo your_username
# Then log out and back in
```

1. Alternative: Run package installation separately as root:

```sh
# Skip package installation in main installer
# Then manually install packages as root
su -c "apt-get install zsh tmux git curl"
```

### Homebrew Not Found (macOS)

**Symptom**: `brew: command not found`

**Solution**:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then add Homebrew to your PATH (the installer will show you the commands).

### Installation Script Exits Prematurely

**Symptom**: Script stops with no error message

**Cause**: The script uses `set -eu` which exits on undefined variables or errors.

**Solution**:

1. Run with verbose output:

```sh
sh -x ./install.sh 2>&1 | tee install.log
```

1. Check the log for the last successful operation and first error.

### Network/Download Failures

**Symptom**: `Cannot reach mise installation server` or `Failed to clone Antidote`

**Solution**:

1. Check internet connectivity:

```sh
ping -c 3 github.com
curl -I https://mise.run
```

1. If behind a proxy, set environment variables:

```sh
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
./install.sh
```

1. If corporate firewall blocks certain URLs, manually install:

```sh
# For mise
curl -fsSL https://mise.run > /tmp/mise-install.sh
# Review the script, then run it
sh /tmp/mise-install.sh

# For Antidote
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

## Post-Installation Issues

### Zsh Not Starting Correctly

**Symptom**: Errors when opening terminal, or prompt looks wrong

**Solution**:

1. Verify zsh is your default shell:

```sh
echo $SHELL
# Should show /bin/zsh or /usr/bin/zsh
```

1. If not, change it:

```sh
chsh -s $(which zsh)
# Log out and back in
```

1. Check for syntax errors:

```sh
zsh -n ~/.zshrc
```

1. Source the config manually to see errors:

```sh
source ~/.zshrc
```

### Symlinks Broken

**Symptom**: Config files show as broken links, or settings don't apply

**Diagnosis**:

```sh
ls -la ~/.zshrc ~/.tmux.conf ~/.config/nvim
```

**Solution**:

1. Re-run symlink setup:

```sh
~/.dotfiles/scripts/setup/setup-symlinks.sh
```

1. If source files are missing, verify dotfiles location:

```sh
ls -la ~/.dotfiles/configs/
```

### Neovim Plugins Not Loading

**Symptom**: Neovim starts but plugins are missing or show errors

**Solution**:

1. Install plugins manually:

```sh
nvim +PlugInstall +qall
```

1. If vim-plug is missing:

```sh
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

1. Update plugins:

```sh
nvim +PlugUpdate +qall
```

### Mise Tools Not Working

**Symptom**: `mise: command not found` or tools installed via mise not available

**Solution**:

1. Ensure mise is in PATH:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

1. Activate mise in your shell:

```sh
eval "$(mise activate zsh)"
```

1. Trust the config file:

```sh
mise trust ~/.dotfiles/mise.toml
```

1. Install tools:

```sh
cd ~/.dotfiles && mise install
```

### Tmux Not Loading Config

**Symptom**: Tmux starts but custom keybindings/theme don't work

**Solution**:

1. Check symlink:

```sh
ls -la ~/.tmux.conf
```

1. Reload config manually:

```sh
tmux source-file ~/.tmux.conf
```

1. Kill all sessions and restart:

```sh
tmux kill-server
tmux
```

### Theme/Prompt Not Displaying Correctly

**Symptom**: Missing characters, wrong colors, or garbled prompt

**Solution**:

1. Ensure terminal supports 256 colors:

```sh
echo $TERM
# Should be xterm-256color or similar
```

1. Install a Nerd Font for icons (optional):
   - Download from <https://www.nerdfonts.com/>
   - Set as terminal font

1. For SSH sessions, ensure TERM is passed:

```sh
ssh -t user@host "export TERM=xterm-256color; zsh"
```

## Backup and Recovery

### Finding Your Backup

Backups are stored with timestamps:

```sh
ls -la ~/.dotfiles_backup/
```

### Restoring Individual Files

```sh
# Find the backup timestamp you want
BACKUP=~/.dotfiles_backup/20240115_143022

# Restore specific files
cp "$BACKUP/.zshrc" ~/
cp "$BACKUP/.tmux.conf" ~/
cp -r "$BACKUP/.config/nvim" ~/.config/
```

### Full Restore

```sh
BACKUP=~/.dotfiles_backup/20240115_143022

# Remove current symlinks
rm ~/.zshrc ~/.tmux.conf ~/.inputrc
rm -rf ~/.config/nvim

# Restore from backup
cp -r "$BACKUP"/* ~/
```

### Manual Backup Before Changes

```sh
~/.dotfiles/scripts/utils/backup.sh
```

## Platform-Specific Issues

### Ubuntu/Debian

**Package not found**:

```sh
sudo apt-get update
sudo apt-cache search package-name
```

**Outdated packages**:

```sh
sudo apt-get upgrade
```

### macOS

**Homebrew permissions**:

```sh
sudo chown -R $(whoami) /usr/local/Homebrew
brew update
```

**Xcode license**:

```sh
sudo xcodebuild -license accept
```

### WSL (Windows Subsystem for Linux)

**Slow disk access**:

- Store dotfiles in the Linux filesystem (`/home/user/`), not Windows (`/mnt/c/`)

**Clipboard integration**:

- Install `win32yank` for clipboard support between WSL and Windows

## Getting Help

### Debug Platform Detection

```sh
~/.dotfiles/scripts/utils/debug_platform.sh
```

### Check POSIX Compliance

```sh
~/.dotfiles/scripts/utils/posix_check.sh
```

### Verbose Installation

```sh
sh -x ./install.sh 2>&1 | tee install.log
```

### Report Issues

When reporting issues, include:

1. Operating system and version: `uname -a`
2. Shell version: `zsh --version`
3. Platform detection output: `./scripts/utils/debug_platform.sh`
4. Error messages from installation log

## Common Error Messages

<!-- prettier-ignore -->
| Error | Meaning | Fix |
| ----- | ------- | --- |
| `platform.sh not found` | Missing utility script | Re-clone repository |
| `Backup script encountered an error` | Backup may be incomplete | Check `~/.dotfiles_backup/` |
| `Package installation encountered an error` | Some packages failed | Install manually |
| `Unknown platform detected` | OS not recognized | See MULTI_PLATFORM.md |
| `mise install encountered an error` | Tool installation failed | Run `mise install` manually |
| `Non-interactive shell detected` | Running without terminal | Expected in scripts/CI |
