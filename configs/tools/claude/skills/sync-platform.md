# sync-platform

Check cross-platform compatibility after config changes.

## When to use

Use when the user edits a config and wants to verify it works
on both Linux and macOS, or when adding a new tool/script that
may have platform-specific behavior.

## Steps

1. **Identify changed files**: Use `git diff --name-only`
   (or user-specified files).

2. **Classify each change** by platform sensitivity:

   - **Shell scripts in `scripts/` and `lib/`**: Must use
     `scripts/utils/platform.sh` guards. Check for:
     - Hardcoded package managers (`apt`, `brew`) without
       `is_linux`/`is_macos` guards
     - Linux-only paths (`/usr/share/`, `/etc/`) vs macOS
       paths (`/usr/local/`, `/opt/homebrew/`)
     - GNU vs BSD command differences
       (`sed -i ''` vs `sed -i`, `grep -P` on macOS)
     - `install_pkg` and `pkg_installed` helper usage
       instead of raw package manager calls

   - **Zsh configs**: Check for:
     - Platform-specific `eval` or `source` paths
       (e.g., brew shellenv on macOS only)
     - Clipboard tools: `xclip`/`xsel` (Linux) vs
       `pbcopy`/`pbpaste` (macOS)
     - Notification tools: `notify-send` (Linux) vs
       `osascript` (macOS)
     - Font paths and locations differ between platforms

   - **Tmux config**: Check for:
     - Copy-pipe commands (`xclip` vs `pbcopy`)
     - `open` (macOS) vs `xdg-open` (Linux)
     - Status bar commands that shell out to
       platform-specific tools

   - **Neovim config**: Check for:
     - System clipboard provider (`xclip` vs `pbcopy`)
     - External tool paths (language servers, formatters)

   - **Tool configs** (`configs/tools/`): Generally portable,
     but check for:
     - Absolute paths that differ between platforms
     - Features that depend on platform-specific backends

3. **Read `scripts/utils/platform.sh`** to understand
   available detection functions and helpers.

4. **Report findings**:
   - For each file, state whether it's platform-safe
     or has issues
   - Show the specific lines with portability problems
   - Suggest fixes using the existing platform detection
     pattern:

     ```sh
     if is_macos; then
       # macOS-specific
     elif is_linux; then
       # Linux-specific
     fi
     ```

   - For Zsh files, suggest
     `[[ "$OSTYPE" == darwin* ]]` /
     `[[ "$OSTYPE" == linux* ]]` guards

5. **Verify fixes** pass `shellcheck --shell=sh` for any
   `.sh` files modified.

## Important rules

- The primary platforms are Linux (Ubuntu/Debian) and macOS.
  Other distros are secondary.
- Scripts in `scripts/` and `lib/` must be POSIX-compliant —
  use `scripts/utils/platform.sh` functions.
- Zsh files in `configs/` may use Zsh-specific syntax
  (`[[ ]]`, arrays, etc.).
- Don't over-guard: if a config is inherently portable
  (e.g., a TOML file with no paths), say so.
- Flag but don't auto-fix ambiguous cases — some platform
  differences are intentional.
