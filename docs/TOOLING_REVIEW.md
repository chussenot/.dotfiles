# Tooling Review

Review of tooling, hooks, and reproducibility for this dotfiles repository.

**Review Date**: 2026-02-03
**Reviewer**: Agent 5 (Tooling, Hooks & Reproducibility)

## Summary

| Finding | Severity | Status |
|---------|----------|--------|
| prek not documented | LOW | Documented below |
| Hook installation not in install.sh | MEDIUM | Needs fix |
| No test suite exists | INFO | Not applicable |
| Man page install correct | OK | No action needed |
| Two hook systems in use | INFO | Documented |

## Detailed Findings

### 1. prek Installation (LOW - Works, underdocumented)

**Status**: `prek` IS installed via mise.

**Location**: `configs/tools/mise/config.toml` line 58:

```toml
prek = "latest"
```

**Verification**:

```sh
$ command -v prek
/home/chussenot/.local/share/mise/installs/prek/0.3.1/prek-x86_64-unknown-linux-musl/prek
```

The alias `alias pre-commit=prek` in `configs/shell/zsh/aliases.zsh` is valid and will
fail loudly with "command not found" if prek is not installed (acceptable behavior).

**prek** is a Rust-based reimagining of pre-commit that:

- Requires no Python or Node.js runtime
- Is a drop-in replacement for pre-commit
- Works with existing `.pre-commit-config.yaml` files

### 2. Hook Installation Not Automated (MEDIUM)

**Issue**: The `install.sh` script does NOT set up git hooks.

On a fresh clone, users must manually run:

```sh
prek install     # For pre-commit hooks
hk install       # For pre-push hooks (optional)
```

**Impact**: Contributors may commit without running linters.

**Recommendation**: Add hook installation to `install.sh` (see fix below).

### 3. Two Hook Systems (INFO)

The repository uses two different hook tools:

| Hook Type | Tool | Config File |
|-----------|------|-------------|
| pre-commit | prek | `.pre-commit-config.yaml` |
| pre-push | hk | `hk.pkl` |

Both are valid tools installed via mise. The `hk.pkl` also defines pre-commit hooks,
but the active `.git/hooks/pre-commit` uses prek.

This is intentional: prek handles the pre-commit linting workflow, while hk manages
the pre-push workflow with mise tasks.

### 4. No Test Suite (INFO - Not Applicable)

The query mentioned `.tests/run-all.sh` but this file/directory does not exist.

**Existing validation**:

- `scripts/utils/posix_check.sh` - POSIX compliance checker
- `.pre-commit-config.yaml` - Automated linting via prek

No formal test suite is required for a dotfiles repository.

### 5. Man Page Installation (OK)

**Status**: Correctly implemented.

The `scripts/setup/install-man-page.sh` script:

1. Copies man page to `~/.local/share/man/man1/keymaps.1`
2. Updates man database via `mandb -q` (if available)
3. Adds MANPATH to `.zshrc` if not present

**Verification**:

```sh
$ man -w keymaps
/home/chussenot/.local/share/man/man1/keymaps.1
```

### 6. Version Pinning (INFO)

Root `mise.toml` has pinned versions (good for reproducibility):

```toml
rust = "1.83"
node = "22"
python = "3.13"
```

But `configs/tools/mise/config.toml` uses `latest` for all tools (50+ tools).

This is documented in `docs/SECURITY_REVIEW.md` as a known trade-off.

## Reproducibility Checklist

For a clean machine install to work:

1. ✅ `git` and `curl` required (documented in README)
2. ✅ mise auto-installed by `install.sh`
3. ✅ Tools installed via `mise install`
4. ⚠️ Git hooks NOT auto-installed (needs fix)

## Recommendations

### Add Hook Installation to install.sh

Add the following after the mise install step:

```sh
# Install git hooks
if command -v prek >/dev/null 2>&1; then
    prek install || print_warning "prek hook installation failed"
fi
```
