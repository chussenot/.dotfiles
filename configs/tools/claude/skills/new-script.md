# new-script

Create a new POSIX-compliant shell script for this dotfiles repository.

## When to use

Use when the user wants to add a new shell script to `scripts/`
(install, setup, or utility), or when creating any `.sh` file
outside of `configs/`. Also use as a reference when modifying
existing scripts and needing a refresher on the required patterns.

## Script template

Every new script in `scripts/` must follow this structure:

```sh
#!/bin/sh

# Brief description of what this script does
# POSIX-compliant version

set -eu

# ── Platform detection ─────────────────────────────────────
# Resolve script directory (POSIX-portable, no readlink -f)
_script_path="$0"
case "${_script_path}" in
/*)
  _script_dir=$(dirname "${_script_path}")
  ;;
*)
  _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
  ;;
esac

# Source platform detection (adjust relative path as needed)
. "${_script_dir}/../utils/platform.sh"
platform_detect

# ── Main logic ─────────────────────────────────────────────
# Your code here. Use platform predicates:
#   is_linux, is_macos, is_ubuntu, is_debian, is_arch
#   is_fedora, is_alpine
#   install_pkg <package>, pkg_installed <package>
```

## POSIX compliance rules

These are hard requirements — CI runs shellcheck across 5 distros
and will reject violations.

| Construct   | Forbidden         | Required                   |
| ----------- | ----------------- | -------------------------- |
| Test        | `[[ ]]`           | `[ ]`                      |
| Variables   | `local var`       | `_var` (underscore prefix) |
| Functions   | `function name`   | `name() {}`                |
| Arrays      | `arr=(a b c)`     | `"a b c"` space-separated  |
| Arithmetic  | `(( x++ ))`       | `$(( x + 1 ))`             |
| Redirection | `&>`, `&>>`       | `>/dev/null 2>&1`          |
| Shebang     | `#!/bin/bash`     | `#!/bin/sh`                |
| Pipefail    | `set -o pipefail` | omit (not POSIX)           |
| Process sub | `<(cmd)`          | use temp files or pipes    |
| Here-string | `<<< "text"`      | `printf '%s' "text" \|`    |
| ANSI-C      | `$'...'`          | use `printf '\n'` etc.     |
| Brace exp.  | `{a,b}`           | list items explicitly      |

## Steps

1. **Determine where the script goes:**
   - `scripts/install/` — package installation
   - `scripts/setup/` — symlink/theme/configuration setup
   - `scripts/utils/` — utilities (debug, backup, validation)

2. **Name the file** using kebab-case:
   `install-packages.sh`, `setup-symlinks.sh`, `debug-platform.sh`.

3. **Write the script** using the template above. Key patterns:
   - **Platform detection**: always source `platform.sh` and call
     `platform_detect` before using any platform predicate
   - **Tool guards**: wrap every external tool call with
     `command -v` checks:

     ```sh
     if command -v curl >/dev/null 2>&1; then
       curl -fsSL "$_url"
     else
       printf 'curl not found, skipping download\n'
     fi
     ```

   - **Color output**: detect TTY before using ANSI codes:

     ```sh
     if [ -t 1 ]; then
       RED='\033[0;31m'
       NC='\033[0m'
     else
       RED=''
       NC=''
     fi
     ```

   - **Paths**: use `${HOME}` or `${DOTFILES_DIR}`,
     never hardcode `/home/<user>`
   - **Printing**: prefer `printf` over `echo` for anything
     beyond trivial output
   - **Temp files**: use `mktemp` (portable)
     instead of hardcoded `/tmp/foo` paths

4. **Cross-platform awareness.** If your script uses any of
   these, add platform guards:
   - `sed -i` — macOS requires `sed -i ''`, Linux uses `sed -i`
   - `readlink -f` — not available on macOS,
     use `cd + pwd` pattern instead
   - `stat` — different flags on GNU vs BSD
   - `date` — format flags differ
   - `grep -P` — not available on macOS
     (use `grep -E` for extended regex)
   - Package managers — use `install_pkg` from platform.sh,
     never call `apt`/`brew` directly

5. **Validate before committing:**

   ```sh
   shellcheck --shell=sh scripts/path/to/your-script.sh
   ```

6. **If the script should run during install**, integrate it
   into `install.sh`:
   - Add it behind a `profile_includes` gate if it's not
     needed in all profiles
   - Ensure it's idempotent — running the installer twice
     must produce the same result

## Important rules

- `#!/bin/sh` — always. No exceptions for scripts in
  `scripts/` or `lib/`.
- Never use `local` — use `_underscore_prefixed` variables
  for function-scoped state.
- Every script must source `platform.sh` and call
  `platform_detect` before using platform predicates. The
  relative path from the script to `platform.sh` varies by
  directory — get it right.
- Zsh-specific features (like `[[ ]]`) are only acceptable
  inside `configs/shell/zsh/*.zsh` files — never in `.sh` files.
- The install flow must remain idempotent after adding
  any new script.
- Run `shellcheck --shell=sh` on every `.sh` file you create
  or modify. Do not claim compliance without running it.
