# Dotfiles

Personal configuration files for a productive development environment using zsh, Neovim, and tmux.

## Quick Start

```sh
# 1. Clone the repository
git clone https://github.com/chussenot/dotfiles.git ~/.dotfiles

# 2. Run the installer
cd ~/.dotfiles && ./install.sh

# 3. Restart your terminal
exec zsh
```

## Platform Support

| Platform | Status | Package Manager |
|----------|--------|-----------------|
| Ubuntu/Debian | Fully supported | apt-get |
| macOS | Fully supported | Homebrew |
| Arch Linux | Partial | pacman |
| Fedora | Partial | dnf |

**Primary Test Environment**: Ubuntu 24.04.3 LTS (kernel 6.14.0-1015-oem)

See [docs/MULTI_PLATFORM.md](docs/MULTI_PLATFORM.md) for detailed platform information.

## Prerequisites

Before running the installer, ensure you have:

| Tool | Required | Purpose |
|------|----------|---------|
| `git` | Yes | Clone repositories (Antidote, dotfiles) |
| `curl` | Yes | Download mise and other tools |
| `sudo` | Linux only | Install system packages |
| `brew` | macOS only | Install packages via Homebrew |

## Installation

### Step-by-Step Guide

#### Step 1: Clone the repository

```sh
git clone https://github.com/chussenot/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

#### Step 2: Review what will be installed (optional but recommended)

```sh
# Check platform detection
./scripts/utils/debug_platform.sh

# Review the install script
less install.sh
```

#### Step 3: Run the installer

```sh
./install.sh
```

#### Step 4: Restart your shell

```sh
exec zsh
# Or close and reopen your terminal
```

#### Step 5: Customize (optional)

```sh
# Local vim overrides
vim ~/.vim/vimrc.local

# Local zsh configuration
vim ~/.zshrc.local
```

### What the Installer Does

The installer performs these steps in order:

1. **Backup** - Creates timestamped backup of existing dotfiles in `~/.dotfiles_backup/`
2. **Install packages** - Installs system packages via your platform's package manager
3. **Install Antidote** - Clones the zsh plugin manager to `~/.antidote`
4. **Create symlinks** - Links configuration files to your home directory
5. **Install mise** - Downloads the tool version manager
6. **Install dev tools** - Uses mise to install Python, Node.js, Go, etc.
7. **Install Neovim plugins** - Runs `:PlugInstall` in headless mode
8. **Install zsh theme** - Sets up the custom `chussenot` theme

### Safety Features

The installer includes several safety measures:

- **Automatic backups**: All existing dotfiles are backed up before modification
- **Non-destructive**: Existing files are moved to `.backup` suffix, not deleted
- **Root protection**: Refuses to run as root user
- **Error handling**: Continues on non-critical failures with warnings
- **Idempotent**: Safe to run multiple times

### Restoring from Backup

If something goes wrong, restore your original configuration:

```sh
# Find your backup
ls ~/.dotfiles_backup/

# Restore specific files
cp ~/.dotfiles_backup/YYYYMMDD_HHMMSS/.zshrc ~/.zshrc

# Or restore everything
cp -r ~/.dotfiles_backup/YYYYMMDD_HHMMSS/* ~/
```

### Uninstalling

To remove the dotfiles and restore your original configuration:

```sh
# 1. Remove symlinks (they point to ~/.dotfiles)
rm ~/.zshrc ~/.tmux.conf ~/.inputrc ~/.config/nvim

# 2. Restore from backup
cp -r ~/.dotfiles_backup/YYYYMMDD_HHMMSS/* ~/

# 3. Remove the dotfiles directory (optional)
rm -rf ~/.dotfiles

# 4. Remove installed tools (optional)
rm -rf ~/.antidote ~/.local/share/mise
```

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

### Quick Fixes

**Installation fails with "permission denied":**

```sh
# Ensure scripts are executable
chmod +x install.sh scripts/**/*.sh
```

**"git not found" or "curl not found":**

```sh
# Ubuntu/Debian
sudo apt-get install git curl

# macOS
xcode-select --install
```

**Symlinks not working:**

```sh
# Re-run symlink setup
./scripts/setup/setup-symlinks.sh
```

**Neovim plugins not loading:**

```sh
# Manually install plugins
nvim +PlugInstall +qall
```

## What's Included

### Core Configuration

| Component | Description | Config Location |
|-----------|-------------|-----------------|
| **Zsh** | Shell with custom theme (no Oh-My-Zsh) | `configs/shell/zsh/` |
| **Neovim** | Editor with vim-plug plugins | `configs/editor/nvim/` |
| **Tmux** | Terminal multiplexer | `configs/terminal/tmux/` |

### Tool Configurations

| Tool | Purpose | Config |
|------|---------|--------|
| [Antidote](https://github.com/mattmc3/antidote) | Zsh plugin manager | `~/.antidote` |
| [mise](https://mise.run) | Version manager for runtimes | `configs/tools/mise/` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | Shell integration |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast code search | - |
| [fd](https://github.com/sharkdp/fd) | Fast file finder | - |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted cat | `configs/tools/bat/` |
| [Atuin](https://github.com/atuinsh/atuin) | Shell history manager | `configs/tools/atuin/` |
| [GitHub CLI](https://cli.github.com) | GitHub from terminal | `configs/tools/gh/` |
| [Glow](https://github.com/charmbracelet/glow) | Terminal markdown viewer | `configs/tools/glow/` |
| [htop](https://htop.dev) | Process viewer | `configs/tools/htop/` |
| [k9s](https://github.com/derailed/k9s) | Kubernetes TUI | `configs/tools/k9s/` |
| [tig](https://github.com/jonas/tig) | Git TUI | `configs/tools/tig/` |

### Container & Cloud Tools

| Tool | Purpose |
|------|---------|
| [Docker](https://www.docker.com) | Container platform |
| [Docker Compose](https://docs.docker.com/compose/) | Multi-container orchestration |
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [Helm](https://helm.sh) | Kubernetes package manager |
| [gcloud](https://cloud.google.com/sdk) | Google Cloud CLI |

### Languages (via mise)

| Language | Version managed by mise |
|----------|------------------------|
| Python | Yes |
| Node.js | Yes |
| Go | Yes |
| Ruby | Yes |
| Rust | Yes |
| Java | Yes |

## Configuration Details

### Tmux

| Setting | Value |
|---------|-------|
| Prefix key | `C-a` (instead of `C-b`) |
| Base index | 1 (instead of 0) |
| Status refresh | 5 seconds |
| Pane navigation | Arrow keys, Alt+arrows without prefix |
| Maximize pane | `\|` key |

### Zsh Theme Features

The `chussenot` theme displays:

- User, host, and current directory
- Git branch and status (clean/dirty indicators)
- Python, Node.js, Go versions (configurable)
- System load with color coding
- Background jobs count
- Active Python virtualenv
- Docker container indicator
- Non-zero exit codes

Configure features via environment variables - see `configs/shell/chussenot.zsh-theme`.

### Neovim

Plugin manager: [vim-plug](https://github.com/junegunn/vim-plug)

Key plugins include autocompletion, fuzzy finding (Telescope), linting, and language-specific support
for Ruby, Python, Go, and Rust.

See `configs/editor/nvim/KEYMAPS.md` for keyboard shortcuts.

## Documentation

- [Multi-Platform Support](docs/MULTI_PLATFORM.md) - Platform detection and package management
- [POSIX Compliance](docs/POSIX_COMPLIANCE.md) - Shell script standards
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Contributing

Contributions to improve cross-platform compatibility are welcome. Please ensure shell scripts pass:

```sh
shellcheck --shell=sh script.sh
```

## License

MIT
