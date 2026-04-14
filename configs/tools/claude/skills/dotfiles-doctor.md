# dotfiles-doctor

Run a comprehensive health check on the dotfiles setup.

## When to use

Use when the user asks "is everything working?",
"check my setup", "dotfiles doctor",
or wants a general health report.

## Steps

1. **Symlink integrity** — Read `symlinks.conf` and for each
   registered symlink:
   - Run `ls -la` on the target path to verify it exists
     and points to the correct source
   - Flag broken symlinks (target missing), orphaned symlinks
     (not in registry), and missing symlinks
     (in registry but not on disk)

2. **Config file consistency**:
   - Every directory in `configs/tools/` should have a
     corresponding entry in `symlinks.conf` — flag orphans
   - Every symlink in `symlinks.conf` should reference an
     existing source file — flag dangling references
   - Check that `.zsh_plugins.txt` references plugins that
     are actually used in `.zshrc`

3. **Tool availability** — Read `mise.toml` and check:
   - Run `mise ls` to see installed vs expected versions
   - Flag tools that are pinned but not installed
   - Flag version mismatches between `mise.toml` and
     what's active

4. **Shell startup health**:
   - Check that `.zshenv` and `.zshrc` don't have syntax
     errors: `zsh -n ~/.zshrc`
   - Verify `antidote` is installed and the plugin bundle
     exists
   - Check for duplicate PATH entries or missing expected
     PATH components

5. **POSIX compliance** of scripts:
   - Run `shellcheck --shell=sh` on all `.sh` files in
     `scripts/` and `lib/`
   - Report any violations (brief summary, not full
     shellcheck output)

6. **Git hooks health**:
   - Check if git hooks are installed
     (`.git/hooks/` or hk configuration)
   - Verify hook scripts are executable

7. **Protected files check**:
   - Verify `configs/shell/fzf/fzf.bash` and
     `configs/shell/fzf/fzf.zsh` use `${HOME}`
     not a hardcoded path
   - Verify they contain the fd integration lines
     (FZF_DEFAULT_COMMAND, etc.)

8. **Report results** as a checklist:

   ```text
   Symlinks .............. 18/18 OK
   Tool configs .......... 8/8 registered
   mise tools ............ 6/6 installed
   Shell syntax .......... OK
   POSIX compliance ...... 12/12 pass
   Git hooks ............. installed
   Protected files ....... OK
   ```

   For any failures, list the specific issue and
   suggested fix.

## Important rules

- Run checks non-destructively — never modify files
  during a health check.
- If a check requires a command that might not be available
  (e.g., `mise`, `shellcheck`), skip gracefully and note
  the missing tool.
- Group findings by severity: errors first, then warnings,
  then informational.
- Keep the summary concise — detailed output only
  for failures.
