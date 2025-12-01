# Tig Configuration

Tig (TUI for Git) configuration with cog integration for conventional commits.

## Color Scheme

Colors are aligned with the chussenot zsh theme:

- **Cyan**: Active elements, info (matches zsh username, VCS info)
- **Green**: Success/positive states (matches zsh hostname, clean VCS)
- **Yellow**: Warnings (matches zsh directory, messages)
- **Red**: Errors/alerts (matches zsh exit codes, dirty VCS)
- **Black**: Background (matches zsh prompt background)
- **White**: Default text (matches zsh default text)

## Standard Keybindings

### Fetch and Pull

- `F` - Fetch from remote
- `U` - Pull from remote

### Push

- `P` - Push to remote

### Stash

- `S` - Stash changes with comment

### Toggle Views

- `<Esc>f` - Toggle file-name display
- `<Esc>f` (main view) - Toggle commit-title-refs

### Branch Management

- `<Esc>u` - Update current branch (checkout, pull, return)

---

## Cog-Tig Integration

Perfect bridge between tig and cog for conventional commits workflow.

### Keybinding Pattern

All cog commands use the **`c`** prefix (c for cog/conventional).
Press `c` followed by another key to run cog commands.

### Available Commands

#### Core Workflow

| Keybinding | Command | Description |
|------------|---------|-------------|
| `c` + `c` | `cog commit` | Create a new conventional commit (replaces regular git commit) |
| `c` + `a` | `git add -A && cog commit` | Stage all files and create a conventional commit (status view) |

#### Verification & Validation

| Keybinding | Command | Description |
|------------|---------|-------------|
| `c` + `h` | `cog check` | Check all commit messages against conventional commit spec |
| `c` + `v` | `cog verify <commit>` | Verify a single commit message (for selected commit in main/log views) |

#### History & Documentation

| Keybinding | Command | Description |
|------------|---------|-------------|
| `c` + `l` | `cog log` | View git log filtered for conventional commits |
| `c` + `g` | `cog changelog` | Display changelog (from latest tag to HEAD) |

#### Version Management

| Keybinding | Command | Description |
|------------|---------|-------------|
| `c` + `V` | `cog get-version` | Get current version from tags |
| `c` + `b` | `cog bump` | Bump version (creates changelog commit and new tag) |

#### Maintenance

| Keybinding | Command | Description |
|------------|---------|-------------|
| `c` + `e` | `cog edit` | Interactively rename invalid commit messages |
| `c` + `i` | `cog install-hook` | Install cog git hooks for automatic validation |

---

## Workflow Examples

### Create a Conventional Commit

1. Stage files in tig status view
2. Press `c` then `c` to open cog commit interface
3. Follow cog's interactive prompts to create a conventional commit

### Quick Commit (Stage All)

1. In status view, press `c` then `a`
2. This stages all files and opens cog commit interface

### Verify Commits

1. Browse commits in main view
2. Select a commit
3. Press `c` then `v` to verify it against conventional commit spec

### View Changelog

1. Press `c` then `g` to see changelog from latest tag to HEAD
2. Useful for reviewing what changed since last release

### Bump Version

1. Press `c` then `b` to create changelog commit and tag
2. This will:
   - Generate changelog from latest tag to HEAD
   - Create a commit with the changelog
   - Create a new version tag

### Check All Commits

1. Press `c` then `h` to verify all commit messages
2. Useful for ensuring repository follows conventional commits

### Install Git Hooks

1. Press `c` then `i` to install cog git hooks
2. This adds automatic validation of commit messages

---

## Benefits

This integration enables:

- ✅ Conventional commits directly from tig
- ✅ Seamless workflow between git operations and commit validation
- ✅ Version management with changelog generation
- ✅ Automatic commit message validation via git hooks
- ✅ Consistent commit message format across the repository

---

## See Also

- [Tig Documentation](https://github.com/jonas/tig)
- [Cog Documentation](https://github.com/cocogitto/cocogitto)
- [Conventional Commits Specification](https://www.conventionalcommits.org/)
