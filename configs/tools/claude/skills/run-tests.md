# run-tests

Run and interpret the test and validation suite for this
dotfiles repository.

## When to use

Use when the user wants to test changes ("run the tests",
"check if this works", "validate my changes"), after modifying
shell scripts, symlinks.conf, install.sh, or platform.sh,
or before committing non-trivial changes. Also use when a CI
workflow fails and the user wants to reproduce locally.

## Validation layers

This repo has four validation layers, from fastest to most thorough:

### 1. Shellcheck (seconds)

Catches POSIX violations, syntax errors, and common shell pitfalls.
Run this first — it's instant.

```sh
# All scripts at once
shellcheck --shell=sh scripts/**/*.sh

# Single file
shellcheck --shell=sh scripts/utils/platform.sh

# Only changed files
git diff --name-only HEAD \
  | grep '\.sh$' \
  | xargs shellcheck --shell=sh
```

What it catches: bashisms (`[[ ]]`, `local`, arrays),
quoting issues, unreachable code, unused variables.

What it misses: logic bugs, cross-platform behavior,
runtime failures.

### 2. POSIX check script (seconds)

A deeper POSIX compliance scan using both shellcheck and
posh (if available).

```sh
./scripts/utils/posix_check.sh
```

Scans all `.sh` files in `scripts/` and `lib/`, checking for the
full POSIX compliance table from CLAUDE.md.

### 3. Pre-commit hooks (seconds)

The repo uses `hk` for git hooks. These run automatically on
commit but can be triggered manually:

```sh
mise run prelint && mise run postlint
```

Covers: prettier formatting, pkl validation, shellcheck.

### 4. Docker integration tests (minutes)

The full test harness. Builds Docker images for 5 distros, runs
the installer inside each, then validates the result. This is the
closest to "does it actually work on a clean machine."

```sh
# Run all distros
./.tests/run-all.sh

# Build and test a single distro manually
docker build \
  -f .tests/docker/Ubuntu-24.04.Dockerfile \
  -t dotfiles-test-ubuntu .
docker run --rm dotfiles-test-ubuntu ./.tests/check.sh
```

Available distros (Dockerfiles in `.tests/docker/`):

- `Ubuntu-24.04.Dockerfile` — primary test target
- `Debian-12.Dockerfile`
- `Alpine.Dockerfile`
- `Archlinux.Dockerfile`
- `Fedora-41.Dockerfile`

Build logs go to `/tmp/docker-build-dotfiles-test-<distro>.log`.

## What check.sh validates

The validation script (`.tests/check.sh`) runs inside the
container and checks:

1. **Symlink integrity** — reads `symlinks.conf` dynamically
   and verifies every registered symlink exists and points to
   the correct source
2. **Antidote installation** — `~/.antidote/` exists
3. **Mise binary** — `mise` command is available
4. **Essential commands** — `zsh`, `git`, `curl` are in PATH
5. **Supporting directories** — `~/.zsh/completions`,
   `~/.local/share/zsh`, etc.

## Which validation to run when

| What changed         | Minimum         | Recommended        |
| -------------------- | --------------- | ------------------ |
| Script in `scripts/` | shellcheck      | + Docker Ubuntu    |
| `symlinks.conf`      | Docker Ubuntu   | Docker all         |
| `install.sh`         | Docker Ubuntu   | Docker all + macOS |
| `platform.sh`        | Docker all      | Docker all         |
| `zsh/*.zsh`          | `zsh -n <file>` | Shell restart      |
| `mise conf.d/*.toml` | `mise install`  | + Docker Ubuntu    |
| macOS-touching       | N/A in Docker   | macOS CI           |

## Interpreting failures

**Docker build fails:**

- Check the build log:
  `cat /tmp/docker-build-dotfiles-test-<distro>.log`
- Common causes: missing package in `install-packages.sh` for
  that distro, network issues during package install, mise tool
  version not available for the distro's architecture

**check.sh fails:**

- Symlink errors: the source file listed in `symlinks.conf`
  doesn't exist in the repo, or `setup-symlinks.sh` didn't run
- Command not found: package installation failed for that
  distro, or mise didn't install the tool
- Directory missing: `setup-symlinks.sh` doesn't create the
  supporting directory

**CI-specific:**

- GitHub Actions workflows are in `.github/workflows/`:
  `lint.yml`, `test-linux.yml`, `test-macos.yml`
- CI sets `MISE_IGNORED_CONFIG_PATHS` to skip heavy tool
  categories in containers
- macOS CI copies the repo to `~/.dotfiles` before running
  (simulates real install path)

## Debugging inside a container

To get a shell inside a test container for investigation:

```sh
docker build \
  -f .tests/docker/Ubuntu-24.04.Dockerfile \
  -t dotfiles-test-ubuntu .
docker run -it --rm dotfiles-test-ubuntu /bin/bash
# Now you can re-run install.sh, check symlinks, etc.
```

## Important rules

- Always run at least `shellcheck --shell=sh` on any modified
  `.sh` file before committing.
- Docker is required for integration tests — if unavailable,
  fall back to shellcheck + local `mise install` + `zsh -n`.
- The primary test target is Ubuntu 24.04.
  If you can only test one distro, use that one.
- Never skip tests on `platform.sh` changes — they affect
  every script in the repo.
- Test harness results in CI are authoritative. If local tests
  pass but CI fails, investigate the CI environment (architecture,
  package availability, PATH differences).
