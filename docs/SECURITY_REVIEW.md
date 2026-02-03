# Security Review Report

**Repository:** /home/chussenot/.dotfiles
**Review Date:** 2026-02-03 (Updated)
**Reviewer:** Agent 3 (Security & Supply Chain)
**Status:** 🟡 PARTIAL - Some issues remain

---

## Executive Summary

This follow-up security review found that **critical issues from the previous review have been fixed**.
However, **2 high**, **4 medium**, and **3 low** severity issues remain or were newly identified.

### Previous Fixes Verified

- ✅ curl|bash pattern fixed - now downloads to temp file first
- ✅ Mise tools pinned (except `hk`)
- ✅ Atuin `secrets_filter = true` enabled
- ✅ K9s `readOnly: true` enabled
- ✅ Critical vim plugins pinned (9 of 70+)
- ✅ PID validation added to kill-click alias
- ✅ Dynamic network interface in capture-creds

### Remaining Issues

| Severity | Count | Key Issues |
| -------- | ----- | ---------- |
| High | 2 | Command injection risk, SSL verification disabled |
| Medium | 4 | Unquoted variables, eval usage, unpinned plugins |
| Low | 3 | Token management, tmux auto-install |

No hardcoded secrets, API keys, or credentials were found.

---

## High Severity Findings

### H-01: Command Injection Risk in git-cloneall Aliases

**Severity:** HIGH
**File:** `configs/shell/zsh/aliases.zsh`
**Lines:** 193-194

```bash
alias git-cloneall-github='... | parallel -j10 "git clone {}"'
alias git-cloneall-gitlab='... | parallel -j10 "git clone {}"'
```

**Description:** `parallel` executes `git clone {}` where `{}` comes from API output.
Malicious repository URLs could inject shell commands.

**Impact:** Remote code execution if API returns crafted URLs.

**Recommendation:** Validate URLs before passing to parallel:

```bash
| grep -E '^git@|^https://' | parallel -j10 git clone {}
```

---

### H-02: SSL Certificate Verification Disabled

**Severity:** HIGH
**File:** `configs/shell/zsh/aliases.zsh`
**Lines:** 193-194, 212-213

```bash
alias git-cloneall-github='curl -sk ...'  # -k disables SSL verification
alias recon-crtsh='f(){ curl -sk "https://crt.sh/..." ...'
```

**Description:** The `-k` flag disables SSL certificate verification,
making connections vulnerable to man-in-the-middle attacks.

**Impact:** Credential theft, data interception.

**Recommendation:** Remove `-k` flags or handle certificates properly:

```bash
alias git-cloneall-github='curl -s ...'  # Remove -k
```

---

## Medium Severity Findings

### M-01: Unquoted Variables in Shell Scripts

**Severity:** MEDIUM
**Files:**

- `scripts/install/install-packages.sh` line 126
- `scripts/utils/backup.sh` line 24

```bash
# install-packages.sh:126
sudo apt-get install -y ${_packages_to_install}

# backup.sh:24
for _file in ${_files_to_backup}; do
```

**Description:** Unquoted variables allow word splitting and glob expansion.

**Recommendation:** Quote variables or use arrays.

---

### M-02: eval Usage in Shell Completions

**Severity:** MEDIUM
**File:** `configs/shell/zsh/_completions.zsh`
**Lines:** 126, 144

```bash
_bash_fallbacks+=("eval 'source <(npm completion)'")
eval "$_cmd" 2>/dev/null || true
```

**Description:** `eval` executes dynamic commands, increasing attack surface.

**Impact:** Code execution if command output is manipulated.

**Recommendation:** Use direct sourcing where possible.

---

### M-03: Unpinned hk Tool Version

**Severity:** MEDIUM
**File:** `mise.toml`
**Line:** 7

```toml
hk = "latest"
```

**Description:** The `hk` tool uses "latest" while other tools are pinned.

**Recommendation:** Pin to specific version:

```toml
hk = "1.35"
```

---

### M-04: Most Vim Plugins Unpinned

**Severity:** MEDIUM
**File:** `configs/editor/nvim/plugs.vim`

**Description:** Of 70+ vim plugins, only 10 are pinned to specific versions.
60+ plugins can auto-update to potentially malicious versions.

**High-risk unpinned plugins using unstable branches:**

- `autozimu/LanguageClient-neovim` - branch: `next`
- `vim-denops/denops.vim` - branch: `main`
- `Shougo/ddc-around` - branch: `main`
- `Shougo/ddc-matcher_head` - branch: `main`
- `Shougo/ddc-sorter_rank` - branch: `main`

**Recommendation:** Pin all plugins to specific tags/commits.

---

## Low Severity Findings

### L-01: Tmux Plugin Manager Auto-Install

**Severity:** LOW
**File:** `configs/terminal/tmux/tmux.conf`
**Line:** 144

```bash
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'"
```

**Description:** TPM is auto-installed from GitHub without verification.

**Recommendation:** Pin to specific tag or document manual installation.

---

### L-02: Git Clone Without Version Pinning

**Severity:** LOW
**Files:**

- `install.sh` line 200 (Antidote)
- `scripts/install/install-packages.sh` line 169 (fzf)

**Description:** Git repositories are cloned without specifying a tag/commit.

**Recommendation:** Add `--branch <tag>` to git clone commands.

---

### L-03: Token Environment Variable Documentation

**Severity:** LOW
**File:** `configs/shell/zsh/aliases.zsh`
**Lines:** 193-194

**Description:** Aliases reference `GITHUB_READ_TOKEN`, `GITLAB_READ_TOKEN`,
and `GITHUB_USER` environment variables. These must be set securely.

**Recommendation:** Document required environment variables and recommend
using a credential manager instead of shell exports.

---

## Verified Security Controls

The following security best practices are in place:

| Control | Status | Location |
| ------- | ------ | -------- |
| No hardcoded secrets | ✅ Pass | Repository-wide |
| Atuin secrets filter | ✅ Enabled | `atuin/config.toml:156` |
| K9s read-only mode | ✅ Enabled | `k9s/config.yaml:9` |
| Mise installer temp file | ✅ Implemented | `install.sh:233` |
| PID validation | ✅ Implemented | `aliases.zsh:143` |
| Insecure aliases commented | ✅ Good | `aliases.zsh` |
| Shell scripts use set -eu | ✅ Good | Multiple scripts |
| pdm.lock for Python deps | ✅ Present | `pdm.lock` |

---

## Remediation Priority

### Immediate (High Priority)

1. **H-01** - Add URL validation to git-cloneall aliases
1. **H-02** - Remove `-k` flags from curl commands

### Short-Term

1. **M-03** - Pin `hk` version in mise.toml
1. **M-01** - Quote variables in shell scripts
1. **M-04** - Pin remaining vim plugins

### Low Priority

1. **M-02** - Review eval usage (standard pattern, acceptable risk)
1. **L-01** - Pin TPM version
1. **L-02** - Pin git clone versions
1. **L-03** - Document token requirements

---

## Files Reviewed

| Category | Files |
| -------- | ----- |
| Shell Scripts | `install.sh`, `scripts/**/*.sh` |
| Shell Config | `configs/shell/zsh/*.zsh` |
| Vim Config | `configs/editor/nvim/plugs.vim` |
| Tool Config | `configs/tools/*/` (atuin, gh, k9s, mise) |
| Tmux Config | `configs/terminal/tmux/tmux.conf` |
| Dependencies | `pyproject.toml`, `mise.toml`, `pdm.lock` |

---

_Review completed 2026-02-03. Next review recommended after remediation._
