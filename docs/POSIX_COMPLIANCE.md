# POSIX Compliance Guide

This project follows the **POSIX.1-2017** standard to ensure maximum portability
across Unix-like systems including Linux, BSD, macOS, BusyBox, Alpine, and
Solaris.

## Why POSIX?

- **Portability**: Scripts work on any POSIX-compliant system
- **Reliability**: Standardized behavior across platforms
- **Maintainability**: Clear, well-defined standards
- **Compatibility**: Works with minimal shell implementations

## POSIX Requirements

### 1. Shebang

**Required:**

```sh
#!/bin/sh
```

**Prohibited:**

- `#!/bin/bash`
- `#!/usr/bin/env bash`
- `#!/usr/bin/env zsh`

### 2. Prohibited Non-POSIX Constructs

#### Bash-specific syntax

| Bashism                   | POSIX Replacement                          |
| ------------------------- | ------------------------------------------ |
| `[[ ... ]]`               | `[ ... ]`                                  |
| `function name() {}`      | `name() {}`                                |
| Arrays `arr=(...)`        | Use positional parameters or other methods |
| `(( ... ))` arithmetic    | `$(( ... ))` or `expr`                     |
| `{1..10}` brace expansion | Use `seq` or loop                          |
| `shopt`                   | Not available                              |
| `=~` regex                | Use `case` or external tools               |
| `local` keyword           | Avoid or use workarounds                   |
| `&>` redirection          | `>/dev/null 2>&1`                          |

#### GNU-specific commands

| GNUism        | POSIX Replacement                             |
| ------------- | --------------------------------------------- |
| `grep -P`     | Use `grep -E` or `awk`                        |
| `grep -oP`    | Use `grep -oE` or `sed`                       |
| `sed -r`      | Use `sed` with basic regex                    |
| `sed -E`      | Use `sed` with basic regex (if not supported) |
| `readlink -f` | Use `cd` + `pwd` workaround                   |

### 3. Required POSIX-Safe Replacements

#### Command substitution

**Use:**

```sh
result=$(command)
```

**Avoid:**

```sh
result=`command`  # Backticks are POSIX but $(...) is preferred
```

#### Output

**Use:**

```sh
printf '%s\n' "message"
```

**Avoid:**

```sh
echo -e "message"  # -e is not POSIX
echo -n "message"   # -n is not POSIX
```

#### Variable quoting

**Always quote variables:**

```sh
"${var}"
"${var:-default}"
```

#### Temporary files

**Use:**

```sh
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
```

#### Command existence

**Use:**

```sh
if command -v cmd >/dev/null 2>&1; then
    # command exists
fi
```

**Avoid:**

```sh
if which cmd >/dev/null 2>&1; then  # which is not POSIX
```

#### Error handling

**Use:**

```sh
set -eu  # Exit on error, undefined variables
```

**Avoid:**

```sh
set -Eeuo pipefail  # -E and -o pipefail are bash-specific
```

#### Script directory detection

**POSIX-compatible:**

```sh
get_script_dir() {
    _script_path="$0"
    _script_dir=""
    case "${_script_path}" in
        /*)
            _script_dir=$(dirname "${_script_path}")
            ;;
        *)
            _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
            ;;
    esac
    printf '%s\n' "${_script_dir}"
}
```

**Avoid:**

```sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Bash-specific
```

#### For loops

**Use:**

```sh
for item in ${list}; do
    [ -z "${item}" ] && continue  # Skip empty items
    # process item
done
```

**Avoid:**

```sh
for item in "${array[@]}"; do  # Arrays are not POSIX
```

## Validation

### Manual Check

Run the POSIX compliance checker:

```sh
./scripts/utils/posix_check.sh
```

### Pre-commit Hook

The project includes a pre-commit hook that automatically validates all shell
scripts for POSIX compliance.

### Tools

#### shellcheck

```sh
shellcheck --shell=sh script.sh
```

#### posh (POSIX shell)

```sh
posh -n script.sh  # Syntax check
```

## Common Patterns

### Array replacement

**Instead of:**

```sh
packages=(zsh tmux git)
for pkg in "${packages[@]}"; do
    install "$pkg"
done
```

**Use:**

```sh
packages="zsh tmux git"
for pkg in ${packages}; do
    [ -z "${pkg}" ] && continue
    install "${pkg}"
done
```

### Arithmetic

**Instead of:**

```sh
((count++))
```

**Use:**

```sh
count=$((count + 1))
```

### Conditional expressions

**Instead of:**

```sh
if [[ $var == "value" ]]; then
```

**Use:**

```sh
if [ "${var}" = "value" ]; then
```

### String matching

**Instead of:**

```sh
if [[ $path =~ /pattern/ ]]; then
```

**Use:**

```sh
case "${path}" in
    */pattern*)
        # match
        ;;
esac
```

## Testing

Test scripts on multiple platforms:

- **Linux**: Standard GNU/Linux
- **macOS**: BSD-based
- **Alpine**: Minimal BusyBox shell
- **Solaris**: Traditional Unix
- **FreeBSD/OpenBSD**: BSD variants

## Resources

- [POSIX.1-2017 Specification](https://pubs.opengroup.org/onlinepubs/9699919799/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [Pure POSIX sh](https://github.com/dylanaraps/pure-sh-bible)

## Checklist

Before committing shell scripts, ensure:

- [ ] Shebang is `#!/bin/sh`
- [ ] No `[[ ... ]]` (use `[ ... ]`)
- [ ] No arrays (use space-separated strings)
- [ ] No `function` keyword (use `name() {}`)
- [ ] No `local` keyword
- [ ] No `(( ... ))` (use `$(( ... ))`)
- [ ] No `echo -e` or `echo -n` (use `printf`)
- [ ] All variables are quoted: `"${var}"`
- [ ] Uses `command -v` instead of `which`
- [ ] Uses `$(...)` instead of backticks
- [ ] Uses `set -eu` instead of `set -Eeuo pipefail`
- [ ] Script directory detection is POSIX-compatible
- [ ] Passes `shellcheck --shell=sh`
- [ ] Passes `posh -n` (if available)

## Files

All shell scripts in this project follow POSIX standards:

| Script                                | Purpose                       |
| ------------------------------------- | ----------------------------- |
| `install.sh`                          | Main installer                |
| `scripts/setup/setup-symlinks.sh`     | Create configuration symlinks |
| `scripts/install/install-packages.sh` | Install system packages       |
| `scripts/utils/backup.sh`             | Backup existing dotfiles      |
| `scripts/utils/platform.sh`           | Platform detection module     |
| `scripts/utils/platform_setup.sh`     | Platform-specific setup       |
| `scripts/utils/debug_platform.sh`     | Debug platform detection      |
| `scripts/utils/posix_check.sh`        | Validate POSIX compliance     |
| `scripts/setup/install-man-page.sh`   | Install man pages             |
| `scripts/setup/install-theme.sh`      | Install zsh theme             |

All scripts are validated for POSIX compliance before commit.

## Related Documentation

- [MULTI_PLATFORM.md](MULTI_PLATFORM.md) - Platform support and package management
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
