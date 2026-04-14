# File — Help Manual

## NAME

**File** — Unified navigation, keybinding, and tooling interface for the development environment.

## SYNOPSIS

```sh
prefix + h          Open this help popup
prefix + f          Fuzzy search sessions and windows
prefix + g          Browse Claude AI conversations
help                Display keybindings in the terminal
```

**Prefix key:** `Ctrl-A`

## DESCRIPTION

File is the central interface layer that ties together shell, editor,
terminal multiplexer, git browser, and fuzzy finder into a cohesive
development environment.

It solves three problems:

1. **Discoverability** — A single place to find every shortcut and capability across tools.
2. **Consistency** — Shared navigation patterns (vi-style motion, prefix-based commands) applied uniformly.
3. **Workflow integration** — Seamless transitions between editing, searching, version control, and session management.

File operates through five integrated environments: ZSH (shell),
FZF (fuzzy finder), TMUX (multiplexer), TIG (git browser), and
Neovim (editor). Each environment exposes its own keybindings,
but File unifies them under a common interaction model.

## HELP NAVIGATION

This document is displayed inside a tmux popup viewer. Standard `less` controls apply.

| Key          | Action                        |
| ------------ | ----------------------------- |
| `j` / `Down` | Scroll down one line          |
| `k` / `Up`   | Scroll up one line            |
| `d`          | Scroll down half a page       |
| `u`          | Scroll up half a page         |
| `g`          | Jump to top                   |
| `G`          | Jump to bottom                |
| `/pattern`   | Search forward for a pattern  |
| `?pattern`   | Search backward for a pattern |
| `n`          | Next search match             |
| `N`          | Previous search match         |
| `q`          | Close the help popup          |

## KEYBINDINGS

### Shell (ZSH)

| Keybinding        | Action                        |
| ----------------- | ----------------------------- |
| `Up` / `Down`     | History substring search      |
| `Ctrl-Left/Right` | Jump word by word             |
| `Ctrl-U`          | Kill line backward            |
| `Ctrl-R`          | Search history via FZF        |
| `Home` / `End`    | Beginning / end of line       |
| `Delete`          | Delete character under cursor |

### Fuzzy Finder (FZF)

| Keybinding | Action                             |
| ---------- | ---------------------------------- |
| `Ctrl-T`   | Find and insert file path          |
| `Ctrl-R`   | Search command history             |
| `Ctrl-C`   | Change directory with fuzzy search |
| `Alt-C`    | Alternative directory change       |
| `Ctrl-J/K` | Navigate results down / up         |
| `Ctrl-N/P` | Alternative navigation             |
| `Enter`    | Select current item                |
| `Escape`   | Cancel and close                   |
| `Ctrl-G`   | Abort search                       |

### Terminal Multiplexer (TMUX)

Prefix key is `Ctrl-A`. Bindings marked **(no prefix)** work without it.

| Keybinding          | Action                                   |
| ------------------- | ---------------------------------------- |
| `a`                 | Send literal Ctrl-A                      |
| `Ctrl-D`            | Detach session **(no prefix)**           |
| `Ctrl-C`            | New window **(no prefix)**               |
| `c`                 | New window (inherits path)               |
| `Ctrl-N` / `Ctrl-P` | Next / previous window                   |
| `^\`                | Last window **(no prefix)**              |
| `s` / `Ctrl-S`      | Horizontal split                         |
| `v` / `Ctrl-V`      | Vertical split                           |
| `\|`                | Toggle pane zoom                         |
| `J/K/H/L`           | Resize pane down/up/left/right           |
| `Alt-Arrow`         | Select pane in direction **(no prefix)** |
| `Ctrl-K` / `Ctrl-J` | Previous / next session (repeatable)     |
| `C`                 | Create new session                       |
| `f`                 | FZF session/window switcher              |
| `g`                 | Claude sessions browser                  |
| `h`                 | Open this help manual                    |
| `k`                 | Kubernetes dashboard (k9s)               |
| `p`                 | Pull requests dashboard (gh-dash)        |
| `t`                 | API client (posting)                     |
| `u`                 | Update dev environment                   |
| `r`                 | Reload tmux configuration                |

### Git Browser (TIG)

| Keybinding | Action                                  |
| ---------- | --------------------------------------- |
| `F`        | Fetch from remote                       |
| `U`        | Pull from remote                        |
| `P`        | Push current branch                     |
| `S`        | Stash changes                           |
| `E`        | Open file in Neovim                     |
| `B`        | Blame view                              |
| `D`        | Diff through delta                      |
| `c`        | Conventional commit (cog)               |
| `ca`       | Stage all + conventional commit         |
| `ch`       | Check commits against conventional spec |
| `cl`       | Conventional commit log                 |
| `cb`       | Bump version (changelog + tag)          |
| `go`       | Open repo in browser (GitHub/GitLab)    |
| `gp`       | View PR/MR for current branch           |
| `gP`       | Create new PR/MR                        |
| `gw`       | Open selected commit in browser         |
| `gl`       | List open PRs/MRs                       |
| `gs`       | Show CI/CD pipeline status              |

SCM bindings auto-detect GitHub (`gh`) or GitLab (`glab`) from the remote URL.

### Editor (Neovim)

Leader key is `Space`.

| Keybinding          | Action                          |
| ------------------- | ------------------------------- |
| `j` / `k`           | Linewrap-aware movement         |
| `Ctrl-Left/Right`   | Previous / next tab             |
| `leader leader`     | Switch to previous buffer       |
| `Ctrl-W Ctrl-D`     | Close current buffer            |
| `Ctrl-K` / `Ctrl-J` | Move line up / down             |
| `gV`                | Select last edited text         |
| `Ctrl-S`            | Save buffer                     |
| `Ctrl-L`            | Clear search highlighting       |
| `Ctrl-T`            | Toggle file tree (NERDTree)     |
| `F2`                | Toggle buffer list (EasyBuffer) |
| `F6`                | Toggle undo tree                |
| `F8`                | Toggle fold                     |
| `//`                | Toggle comment                  |
| `gh` / `gH`         | Next / previous git hunk        |
| `K`                 | LSP hover information           |
| `gd`                | Go to definition                |
| `grn`               | Rename symbol                   |
| `gra`               | Code action                     |
| `grr`               | Find references                 |
| `Tab` / `Shift-Tab` | Next / previous completion item |
| `Ctrl-Space`        | Trigger completion              |
| `Space`             | which-key popup (wait briefly)  |

## FEATURES

### Session Management

Switch between projects without losing context. TMUX sessions persist
across detach/reattach cycles and are auto-saved every 10 minutes
via tmux-continuum.

- `prefix + f` opens a fuzzy session/window switcher. Type a name to filter or create a new session.
- `prefix + C` creates a named session via prompt.
- `Ctrl-K` / `Ctrl-J` cycle through sessions without a prefix.

### Claude AI Integration

Browse and resume Claude CLI conversations grouped by project.

- `prefix + g` opens the Claude sessions browser with a live preview.
- Selecting a session opens it in a new tmux window via `claude -r`.
- If the session is already open, focus switches to its window.

### Fuzzy Search

FZF powers file discovery, history search, directory navigation, and session switching.

- `Ctrl-T` inserts a file path into the current command.
- `Ctrl-R` replaces the default history search with a fuzzy, ranked interface.
- `Ctrl-C` or `Alt-C` jumps to a directory anywhere in the tree.
- FZF uses `fd` as the default file finder when available, respecting `.gitignore`.

### Git Workflow

TIG provides a terminal UI for git with integrated conventional commit support via `cog`.

- Press `c` to author a conventional commit with type, scope, and description prompts.
- Press `D` to view rich diffs rendered by delta.
- SCM bindings (`go`, `gp`, `gP`, `gl`, `gs`) auto-detect GitHub or GitLab.

### LSP and Completion

Neovim provides language-aware editing through `nvim-lspconfig` and `nvim-cmp`.

- `K` shows hover docs for the symbol under the cursor.
- `gd` jumps to definition; `grr` lists all references.
- `Tab` cycles through completion suggestions; `Ctrl-Space` triggers them manually.
- `Space` activates which-key for a popup of available leader mappings.

### Copy and Clipboard

TMUX copy mode uses vi-style selection with system clipboard integration.

- Enter copy mode with `prefix + [`.
- Press `v` to start selection, `y` to yank to clipboard.
- Clipboard backend auto-detects: `pbcopy` (macOS), `xclip` or `wl-copy` (Linux).

## TOOLING

| Tool        | Role                    | Integration                                          |
| ----------- | ----------------------- | ---------------------------------------------------- |
| **ZSH**     | Shell and command entry | History substring search, vi-compatible line editing |
| **FZF**     | Fuzzy finder            | File search, history, directory jump, session switch |
| **TMUX**    | Terminal multiplexer    | Sessions, windows, panes, popups, plugin ecosystem   |
| **TIG**     | Git terminal UI         | Commit, push, fetch, blame, delta diff, SCM links    |
| **Neovim**  | Editor                  | LSP, completion, file tree, git hunks, which-key     |
| **mise**    | Tool version manager    | Pins runtime versions (rust, node, python, etc.)     |
| **delta**   | Diff renderer           | Rich, syntax-highlighted diffs inside TIG            |
| **cog**     | Conventional commits    | Structured commit messages, version bumping          |
| **fd**      | File finder             | Fast, gitignore-aware backend for FZF                |
| **gh/glab** | SCM CLI                 | PR/MR management, CI status, repo browsing           |
| **gh-dash** | GitHub dashboard        | PR/issue dashboard across repos via `prefix + p`     |
| **posting** | API client              | TUI HTTP client for testing APIs via `prefix + t`    |

## WORKFLOWS

### Navigate between projects

1. Press `prefix + f` to open the session switcher.
2. Type a project name to filter existing sessions.
3. If no match exists, press Enter to create a new session with that name.
4. Use `Ctrl-K` / `Ctrl-J` to cycle sessions quickly.

### Edit a file

1. In ZSH, press `Ctrl-T` to fuzzy-find a file.
2. Open it in Neovim.
3. Use `gd` to jump to definitions, `K` for hover docs.
4. Press `Ctrl-S` to save, `//` to toggle comments.
5. Use `gh` / `gH` to navigate git hunks.

### Commit changes

1. Open TIG from the shell.
2. Review staged changes with `D` for rich diffs.
3. Press `c` to create a conventional commit.
4. Press `P` to push, `gs` to check CI status.
5. Press `gP` to open a PR/MR creation page in the browser.

### Resume a Claude conversation

1. Press `prefix + g` to open the Claude sessions browser.
2. Browse conversations grouped by project.
3. Select a session to resume it in a new tmux window.

### Discover keybindings

1. Press `prefix + h` to open this help popup.
2. Use `/` to search for a specific action or key.
3. Press `q` to close and return to your work.

## EXAMPLES

Open the help popup:

```sh
Ctrl-A h
```

Fuzzy-find and open a file:

```sh
Ctrl-T → type filename → Enter → nvim opens the file
```

Create a new tmux session for a project:

```sh
Ctrl-A f → type "myproject" → Enter
```

Conventional commit after staging:

```sh
tig → ca → select type → enter scope → write message
```

Search command history:

```sh
Ctrl-R → type partial command → Enter
```

Check CI status from TIG:

```sh
tig → gs → view pipeline results
```

## FILES

| Path                                          | Description                    |
| --------------------------------------------- | ------------------------------ |
| `~/.dotfiles/help.md`                         | This help document             |
| `~/.dotfiles/configs/shell/zsh/.zshrc`        | ZSH configuration              |
| `~/.dotfiles/configs/shell/zsh/functions.zsh` | Shell functions                |
| `~/.dotfiles/configs/terminal/tmux/tmux.conf` | TMUX configuration             |
| `~/.dotfiles/configs/tools/tig/tigrc`         | TIG configuration              |
| `~/.dotfiles/configs/editor/nvim/`            | Neovim configuration directory |
| `~/.dotfiles/mise.toml`                       | Tool version pins              |

## SEE ALSO

`tmux(1)`, `fzf(1)`, `nvim(1)`, `zsh(1)`, `tig(1)`, `man(1)`
