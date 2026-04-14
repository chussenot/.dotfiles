# add-config

Scaffold a new tool configuration into this dotfiles repository.

## When to use

Use when the user wants to add configuration for a new tool
(e.g., "add starship config", "add lazygit config",
"set up delta config").

## Steps

1. **Ask** the user for:
   - The tool name (e.g., `starship`, `lazygit`, `delta`)
   - The config file name and format if not obvious
     (e.g., `starship.toml`, `config.yml`)
   - Where the tool expects its config at runtime
     (e.g., `~/.config/starship/starship.toml`)

2. **Create the config directory and file** under
   `configs/tools/<tool-name>/`:

   ```text
   configs/tools/<tool-name>/<config-file>
   ```

   Populate with sensible defaults or the content the
   user provides.

3. **Register the symlink** in `scripts/setup/symlinks.conf` —
   this is the single source of truth for all symlinks.
   Both `setup-symlinks.sh` and `.tests/check.sh` parse this file.

   Add a line following the existing format:

   ```text
   configs/tools/<tool-name>/<config-file>|${HOME}/.config/<tool-name>/<config-file>
   ```

   The format is: `source_relative_path|${HOME}/target_path`

   Place the new entry in the `# Tools` section, keeping entries
   in roughly alphabetical order. Look at existing entries for
   reference — some tools use XDG paths (`~/.config/<tool>/`),
   others use dotfiles in home (`~/.<tool>rc`). Match what the
   tool actually expects.

   For directory symlinks (when the whole config dir should
   be linked), point to the directory:

   ```text
   configs/tools/<tool-name>|${HOME}/.config/<tool-name>
   ```

4. **Verify** the source file exists in the repo (the path you
   just added to symlinks.conf must resolve to a real file
   or directory).

5. **Test the symlink** by running:

   ```sh
   ./scripts/setup/setup-symlinks.sh
   ```

   Confirm the symlink was created at the target path.

6. **If the tool is managed by mise**, also add it to the
   appropriate `configs/tools/mise/conf.d/` file (see the
   `add-mise-tool` skill for details on category selection
   and version pinning).

## Important rules

- **`symlinks.conf` is the single source of truth** — never
  edit `setup-symlinks.sh` to add symlinks. The script reads
  from `symlinks.conf` dynamically.
- Source paths in `symlinks.conf` are relative to the
  dotfiles root directory.
- Target paths must use `${HOME}` — never hardcode a literal
  home path like `/home/username`.
- Do NOT change the `symlinks.conf` format (pipe-delimited,
  comments with `#`). Both `setup-symlinks.sh` and
  `.tests/check.sh` parse it.
- Follow existing naming conventions: kebab-case directory
  names under `configs/tools/`, config file names matching
  what the tool expects.
- Some tools use `~/.config/<tool>/` (XDG standard), others
  use `~/.<tool>rc` or `~/.<tool>.toml` — match the tool's
  actual expectation.
- Do NOT add install logic here. Package installation belongs
  in `scripts/install/` or mise `conf.d/` files.
- If the tool needs Zsh completion or shell integration,
  mention it to the user but don't auto-add it to `.zshrc`.
- Never modify the protected fzf files
  (`configs/shell/fzf/fzf.bash`, `configs/shell/fzf/fzf.zsh`).
