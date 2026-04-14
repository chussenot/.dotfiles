# migrate-tool

Replace one tool with another across the entire dotfiles setup.

## When to use

Use when the user wants to swap a tool for an alternative
(e.g., `nvm` to `mise`, `oh-my-zsh` to `antidote`,
`vim` to `neovim`, `grep` to `ripgrep`, `cat` to `bat`).

## Steps

1. **Confirm the migration** with the user:
   - Source tool (being replaced)
   - Target tool (replacement)
   - Ask if they want a clean removal or a soft deprecation
     (keep old config as backup)

2. **Trace all references** to the source tool across the
   entire repo. Search in:
   - `configs/shell/zsh/.zshrc` — aliases, eval statements,
     PATH entries, plugin references
   - `configs/shell/zsh/.zshenv` — environment variables, PATH
   - `configs/shell/zsh/aliases.zsh` — tool-specific aliases
   - `configs/shell/zsh/functions.zsh` — wrapper functions
   - `configs/shell/zsh/_completions.zsh` — completion setup
   - `configs/shell/zsh/.zsh_plugins.txt` — antidote plugins
   - `configs/tools/` — dedicated config directories
   - `configs/terminal/tmux/tmux.conf` — tmux integrations
   - `configs/editor/nvim/` — neovim plugin/integration refs
   - `scripts/install/` — package installation logic
   - `scripts/setup/symlinks.conf` — symlink registrations
   - `mise.toml` — version-managed tools
   - `install.sh` — top-level install flow

   Use `Grep` with the tool name and common variants
   (binary name, package name, env var prefix).

3. **Present a migration plan** before making changes:
   - List every file and line that references the source tool
   - For each reference, show what the replacement looks like
   - Flag any references that need user input
     (e.g., different config syntax)
   - Note if the target tool needs new config files or
     different symlink paths

4. **Execute the migration** after user approval:
   - Update aliases and functions to use the new tool
   - Replace eval/init statements
   - Update or create config in `configs/tools/<new-tool>/`
   - Update `symlinks.conf`
     (remove old symlink, add new one)
   - Update `scripts/install/` if the install method changes
   - Update `mise.toml` if the new tool should be
     version-managed
   - Remove old config directory from
     `configs/tools/<old-tool>/` if user chose clean removal
   - Update antidote plugin list if shell plugins change

5. **Verify the migration**:
   - Run `shellcheck --shell=sh` on any modified `.sh` files
   - Check that no orphan references to the old tool remain
     (grep again)
   - Confirm new symlinks are registered

## Important rules

- ALWAYS show the full migration plan and get user
  confirmation before editing files.
- When removing a tool's config directory, confirm with the
  user first — it may contain customizations.
- Maintain POSIX compliance in all `.sh` files.
- If the source tool has shell completions, ensure the
  target tool's completions are set up too.
- Some migrations are partial (e.g., tool handles only some
  functions of the old one) — flag gaps.
- Never modify `configs/shell/fzf/fzf.bash` or
  `configs/shell/fzf/fzf.zsh` — they are protected.
