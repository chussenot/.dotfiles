# diagnose

Diagnose shell, terminal, and tooling issues in this
dotfiles setup.

## When to use

Use when the user reports a problem like "my shell is slow",
"colors are wrong", "completions don't work",
"tmux keybindings broken", "mise not loading", etc.

## Steps

1. **Clarify the symptom** if needed: what's broken,
   when it started, which terminal/shell.

2. **Read the relevant config files** based on the symptom:

   - **Shell slow/startup**: Read `configs/shell/zsh/.zshrc`,
     `configs/shell/zsh/.zshenv`,
     `configs/shell/zsh/.zsh_plugins.txt`. Look for:
     - Heavy plugin list (too many antidote plugins)
     - Synchronous eval calls that could be lazy-loaded
     - Redundant PATH manipulations
     - Missing or broken completions cache (`zcompdump`)
     - `mise activate` without `--shims` in
       non-interactive contexts

   - **Colors/theme wrong**: Read
     `configs/terminal/tmux/tmux.conf`,
     `configs/shell/zsh/.zshrc`,
     `configs/editor/nvim/init.vim`. Check for:
     - Missing `set -g default-terminal "tmux-256color"`
     - Conflicting TERM exports in `.zshrc` vs `.zshenv`
     - Neovim `termguicolors` not set
     - Theme not installed or path wrong

   - **Completions broken**: Read
     `configs/shell/zsh/.zshrc`,
     `configs/shell/zsh/_completions.zsh`,
     `configs/shell/zsh/.zsh_plugins.txt`. Check for:
     - `compinit` called before completion plugins
     - Missing `fpath` entries
     - Stale `zcompdump` (suggest `rm ~/.zcompdump*`)
     - Tool-specific completions not sourced

   - **Tmux issues**: Read
     `configs/terminal/tmux/tmux.conf`. Check for:
     - Conflicting prefix key bindings
     - Plugin manager (tpm) not installed or not loading
     - Status bar referencing missing programs
     - Copy-mode incompatible with platform
       (xclip vs pbcopy)

   - **Tool not found / not loading**: Check `mise.toml`,
     `configs/shell/zsh/.zshenv`,
     `configs/shell/zsh/.zshrc`. Verify:
     - Tool is in `mise.toml` with a pinned version
     - `mise activate` is sourced in the shell
     - PATH includes `~/.local/share/mise/shims`
     - Symlink exists and points to correct source

3. **Check symlink health** for the affected tool:
   - Verify the symlink in `symlinks.conf` exists for
     this config
   - Run `ls -la` on the expected symlink target to
     confirm it's not broken

4. **Cross-reference platform**: Read
   `scripts/utils/platform.sh` and check if the issue might
   be platform-specific (e.g., macOS vs Linux clipboard,
   brew vs apt paths).

5. **Report findings**:
   - State the likely root cause
   - Show the specific lines in config files causing the issue
   - Provide a concrete fix (edit to make, command to run)
   - If uncertain, list 2-3 possible causes ranked by
     likelihood

## Important rules

- Always read the actual config files before diagnosing —
  never guess from memory.
- Check for interactions between configs
  (e.g., tmux TERM setting vs shell TERM export).
- If the fix involves editing a `.sh` file, ensure POSIX
  compliance is maintained.
- Suggest the least invasive fix first.
