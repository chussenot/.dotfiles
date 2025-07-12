# Dotfiles Organization Improvement Plan

## Current Issues

1. Mixed file locations (some in root, some in dotfiles/)
2. No clear separation between different types of configs
3. Missing documentation for each component
4. No version management for tools
5. Inconsistent naming conventions

## Proposed New Structure

```bash
~/.dotfiles/
├── README.md
├── install.sh
├── bootstrap.sh
├── scripts/
│   ├── install/
│   │   ├── install-packages.sh
│   │   ├── install-oh-my-zsh.sh
│   │   └── install-tools.sh
│   ├── setup/
│   │   ├── setup-symlinks.sh
│   │   ├── setup-git.sh
│   │   └── setup-ssh.sh
│   └── utils/
│       ├── backup.sh
│       ├── restore.sh
│       └── update.sh
├── configs/
│   ├── shell/
│   │   ├── zsh/
│   │   │   ├── zshrc
│   │   │   ├── aliases.zsh
│   │   │   ├── functions.zsh
│   │   │   ├── plugins.zsh
│   │   │   └── theme.zsh
│   │   └── bash/
│   │       └── bashrc
│   ├── terminal/
│   │   ├── tmux/
│   │   │   ├── tmux.conf
│   │   │   ├── plugins.tmux
│   │   │   └── scripts/
│   │   │       └── tmux_controller.py
│   │   └── alacritty/
│   │       └── alacritty.yml
│   ├── editor/
│   │   ├── nvim/
│   │   │   ├── init.lua
│   │   │   ├── lua/
│   │   │   │   ├── plugins.lua
│   │   │   │   ├── keymaps.lua
│   │   │   │   └── settings.lua
│   │   │   └── after/
│   │   └── vscode/
│   │       └── settings.json
│   ├── tools/
│   │   ├── git/
│   │   │   ├── config
│   │   │   └── ignore
│   │   ├── mise/
│   │   │   └── tool-versions
│   │   └── fzf/
│   │       └── fzf.zsh
│   └── system/
│       ├── systemd/
│       └── udev/
├── local/
│   ├── zsh/
│   │   └── local.zsh
│   └── git/
│       └── local-config
├── themes/
│   ├── zsh/
│   └── tmux/
├── plugins/
│   ├── zsh/
│   └── nvim/
└── docs/
    ├── INSTALLATION.md
    ├── CONFIGURATION.md
    ├── TROUBLESHOOTING.md
    └── components/
        ├── zsh.md
        ├── tmux.md
        ├── nvim.md
        └── tools.md
```

## Key Improvements

### 1. Modular Configuration

- Split large config files into smaller, focused modules
- Separate concerns (aliases, functions, plugins, themes)
- Easy to enable/disable specific features

### 2. Local Overrides

- `local/` directory for machine-specific configs
- Never committed to git
- Allows personal customizations

### 3. Better Documentation

- Component-specific documentation
- Installation and troubleshooting guides
- Clear separation of concerns

### 4. Improved Scripts Organization

- Categorized scripts by purpose
- Reusable installation scripts
- Backup and restore functionality

### 5. Version Management

- Clear tool version specifications
- Reproducible environments
- Easy updates

## Migration Steps

1. **Create new structure**
2. **Move existing files**
3. **Split large configs**
4. **Add documentation**
5. **Update installation script**
6. **Test on clean system**

## Benefits

- **Maintainability**: Easier to find and modify specific configs
- **Portability**: Better cross-platform support
- **Modularity**: Can use only what you need
- **Documentation**: Clear guides for each component
- **Backup**: Easy backup and restore functionality
- **Local Customization**: Machine-specific settings without conflicts
