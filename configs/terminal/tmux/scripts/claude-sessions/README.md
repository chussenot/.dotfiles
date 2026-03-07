# Claude Sessions Browser

Browse and resume Claude CLI conversations directly from tmux.

`Prefix + g` opens a floating popup listing every Claude conversation,
grouped by project, with a live preview on the right. Select one to
instantly resume it in a new tmux window via `claude -r`.

## Requirements

- tmux >= 3.2 (for `display-popup`)
- fzf
- Python 3
- `claude` CLI in `$PATH`

## How it works

Claude CLI stores conversations in `~/.claude/projects/` using an encoded
directory naming scheme: each project path is flattened by replacing `/`
with `-` and `.` with `--`.

For example, `/home/alice/.dotfiles` becomes `-home-alice--dotfiles`.

| Script       | Purpose                                                                                                                     |
| ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `picker.py`  | Scans `~/.claude/projects/`, reverses the path encoding via a greedy filesystem walk, and emits tab-delimited lines for fzf |
| `preview.py` | Renders the selected conversation with colored role badges (`you` / `claude`)                                               |
| `popup.sh`   | Entry point launched inside the tmux popup -- pipes picker through fzf, then calls open.sh                                  |
| `open.sh`    | Opens `claude -r <session-id>` in a new tmux window, or switches to an existing one                                         |

## Keybindings

Inside the popup:

| Key                                  | Action                      |
| ------------------------------------ | --------------------------- |
| `Enter`                              | Open selected session       |
| `Esc` / `Ctrl-c`                     | Close popup                 |
| `Up` / `Down` or `Ctrl-k` / `Ctrl-j` | Move selection              |
| `J` / `K`                            | Scroll preview down / up    |
| `g` / `G`                            | Preview top / bottom        |
| `Ctrl-d` / `Ctrl-u`                  | Preview half-page down / up |
| `Ctrl-f` / `Ctrl-b`                  | Preview full page down / up |
| `/`                                  | Toggle preview pane         |
| Type anything                        | Fuzzy-filter sessions       |

## Configuration

The tmux binding is defined in `configs/terminal/tmux/tmux.conf`:

```tmux
bind g display-popup -w "80%" -h "75%" -E "bash ~/.dotfiles/configs/terminal/tmux/scripts/claude-sessions/popup.sh"
```
