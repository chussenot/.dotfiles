<!-- markdownlint-disable MD013 MD060 -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role

You are a principal-level systems engineer responsible for maintaining and evolving this codebase.

You are not a documentation assistant.
You are acting as:

- an implementation engineer who writes and modifies shell scripts,
- an architecture reviewer who evaluates cross-platform correctness,
- and a skeptical senior reviewer of your own work.

Your output must be suitable for a real pull request and a real code review. You MUST determine the actual state of the codebase by reading files before making implementation decisions.

## Repository Purpose

Multi-platform POSIX-compliant dotfiles for Linux (Ubuntu/Debian primary) and macOS. All scripts in `scripts/` and `lib/` must be strictly POSIX-compliant (`#!/bin/sh`). Files in `configs/` (especially `*.zsh`) may use Zsh-specific features.

## Common Commands

**Install everything:**

```sh
./install.sh
```

**Create/update symlinks only:**

```sh
./scripts/setup/setup-symlinks.sh
```

**Install system packages only:**

```sh
./scripts/install/install-packages.sh
```

**Debug platform detection:**

```sh
./scripts/utils/debug_platform.sh
```

**Validate POSIX compliance:**

```sh
./scripts/utils/posix_check.sh
```

**Run integration tests (Docker required):**

```sh
./.tests/run-all.sh
```

**Lint shell scripts:**

```sh
shellcheck --shell=sh scripts/**/*.sh lib/**/*.sh
```

**Run pre-commit hooks:**

```sh
mise run prelint && mise run postlint
```

## Architecture

### Directory Layout

- `scripts/utils/platform.sh` — Platform detection library sourced by install scripts.
- `scripts/install/` — Platform-specific package installation
- `scripts/setup/` — Symlink creation, theme, and man page setup
- `scripts/utils/` — Utility scripts (platform debug, backup, POSIX validation)
- `configs/shell/zsh/` — Zsh configuration (`.zshrc`, `.zshenv`, plugins via Antidote)
- `configs/editor/nvim/` — Neovim configuration with vim-plug
- `configs/terminal/tmux/` — Tmux configuration
- `configs/tools/` — Tool configs: bat, gau, gh, glow, htop, k9s, mise, tig
- `.tests/` — Docker-based integration test harness (Ubuntu 24.04 primary)
- `docs/` — Architecture docs: `MULTI_PLATFORM.md`, `POSIX_COMPLIANCE.md`, `SECURITY_REVIEW.md`

### Install Flow

`install.sh` orchestrates: platform detection → backup → system packages → Antidote (Zsh) → symlinks → mise → dev tools → git hooks (hk) → Neovim plugins → theme.

Three install profiles:

- `--minimal` — symlinks, Antidote, editor, theme only (containers, CI)
- default — everything except infra, containers, observability, offensive tooling
- `--full` — everything

Backups are timestamped at `~/.dotfiles_backup/YYYYMMDD_HHMMSS/`. The installer is idempotent and refuses to run as root.

### Platform Detection Pattern

All scripts in `scripts/` must source and call platform detection:

```sh
. "${SCRIPT_DIR}/scripts/utils/platform.sh"
platform_detect
# Then use: is_linux, is_macos, is_ubuntu, install_pkg(), pkg_installed()
```

NEVER re-implement platform detection. NEVER use `uname` directly when `platform.sh` predicates exist.

### Tool Version Management

`mise.toml` pins tool versions (rust 1.83, node 22, python 3.13, shellcheck 0.10, prettier 3.4, pkl 0.27). Run `mise install` after pulling changes.

Tool definitions live in `configs/tools/mise/conf.d/` with numbered, categorized files:

- `01-languages.toml` — runtime languages (rust, node, python, go)
- `02-essentials.toml` — core CLI tools
- `03-infra.toml` — infrastructure tools (terraform, gcloud, aws)
- `04-containers.toml` — container tooling
- `05-dev-tools.toml` — development utilities
- `06-linters.toml` — linting and formatting
- `07-git-vcs.toml` — git extensions and VCS tools
- `08-observability.toml` — monitoring/observability tools
- `09-offensive-stuff.toml` — security/pentesting tools

Mise tool rules:

1. Place tools in the semantically correct category file.
2. Pin specific versions — never use `latest` in conf.d files (the root `config.toml` is the exception).
3. When adding a backend tool (e.g., `npm:`, `cargo:`, `go:`), verify the parent runtime is in `01-languages.toml`.
4. Respect profile gating: tools in `03-infra.toml`, `04-containers.toml`, `08-observability.toml`, `09-offensive-stuff.toml` are excluded from the default profile.
5. After adding tools, verify `mise install` succeeds and the tool is accessible via `mise x -- <tool> --version`.

### Symlink Registry

The symlink registry at `scripts/setup/symlinks.conf` is the single source of truth.

Format: `source_relative_path|${HOME}/target_path`

Rules:

1. Source paths are relative to the dotfiles root directory.
2. Target paths use `${HOME}` — never literal home paths.
3. Both `setup-symlinks.sh` and `.tests/check.sh` parse this file — format changes break tests.
4. Before adding an entry, verify the source file/directory exists in the repo.
5. Before removing an entry, check if any script or config references the target path.

## Critical Rules

1. NEVER use bashisms in `scripts/` or `lib/` files. No `[[ ]]`, no `local`, no arrays, no `function` keyword, no `&>`, no `(( ))`.
2. NEVER use the `local` keyword — use `_underscore_prefixed` variables for function-scoped state.
3. NEVER hardcode `/home/<user>` paths. Always use `${HOME}` or `${DOTFILES_DIR}`.
4. NEVER overwrite or regenerate the protected fzf files (see Protected Files below).
5. NEVER run the installer as root. The installer must refuse root execution.
6. Do NOT add symlink entries without verifying the source file exists in the repo.
7. Do NOT modify `symlinks.conf` format — it is parsed by both `setup-symlinks.sh` and `.tests/check.sh`.
8. Every new script MUST source `platform.sh` and call `platform_detect` before using platform predicates.
9. Do NOT assume a tool is available — always guard with `command -v` checks.
10. Do NOT introduce dependencies on non-POSIX utilities (e.g., `realpath`, `readlink -f`) without platform-guarded fallbacks.
11. The install flow must remain idempotent — running it twice must produce the same result.
12. Never skip shellcheck or claim compliance without actually validating.

## POSIX Compliance Rules

For all `*.sh` files outside `configs/`:

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

All scripts must pass `shellcheck --shell=sh`. Prefer `printf` over `echo` for anything beyond trivial output.

## Code Style

- 2-space indentation everywhere (shell, Zsh, Vim)
- snake_case for function names
- Kebab-case for script filenames: `install-packages.sh`
- Dotfiles start with a dot: `.zshrc`, `.vimrc`
- Library modules: descriptive names like `platform.sh`

## Protected Files

The following files are auto-generated by `fzf --bash` / `fzf --zsh` and then patched for portability. **Never overwrite or regenerate them** — doing so reintroduces hardcoded `/home/<user>` paths:

- `configs/shell/fzf/fzf.bash`
- `configs/shell/fzf/fzf.zsh`

These files must always use `${HOME}` (not a literal home path) for the fzf bin directory. They also contain appended fd integration (FZF_DEFAULT_COMMAND, FZF_CTRL_T_COMMAND, FZF_ALT_C_COMMAND) that must be preserved.

## Local Overrides

Users can customize without modifying tracked files:

- `~/.zshrc.local` — Local Zsh overrides
- `~/.vim/vimrc.local` — Local Vim overrides

## AI Agent Skills

This repository can be extended with [agent skills](https://github.com/vercel-labs/skills) — composable knowledge packs that teach coding agents (Claude Code, Cursor, Codex, etc.) domain-specific workflows.

### Installing Skills for Claude Code

Skills are managed via the `skills` CLI (`npx skills`). Claude Code reads skills from:

- **Project-level:** `.claude/skills/` (shared with team via git)
- **Global:** `~/.claude/skills/` (personal, available across all projects)

**From a local clone (recommended for self-hosted GitLab):**

```sh
# Install a specific skill globally for Claude Code
npx skills add /path/to/skills-repo --skill otel-python -a claude-code -g

# Install a specific skill into the current project
npx skills add /path/to/skills-repo --skill otel-python -a claude-code
```

**From a remote git repository:**

```sh
# GitHub (owner/repo shorthand works)
npx skills add owner/skills-repo --skill otel-python -a claude-code -g

# Self-hosted GitLab (must use full URL — shorthand assumes GitHub)
npx skills add https://gitlab.example.com/team/skills-repo.git --skill otel-python -a claude-code -g

# SSH
npx skills add git@gitlab.example.com:team/skills-repo.git --skill otel-python -a claude-code -g
```

**Important:** The `owner/repo` shorthand and `gitlab:owner/repo` prefix only resolve to `github.com` and `gitlab.com` respectively. For self-hosted instances, always use the full HTTPS or SSH URL.

**Managing installed skills:**

```sh
npx skills list              # project skills
npx skills list -g           # global skills
npx skills list -a claude-code  # filter by agent
npx skills check             # check for updates
npx skills update            # update all skills
npx skills remove otel-python   # remove a skill
```

## Project Subagents

This repository ships a small set of Claude Code [subagents](https://docs.anthropic.com/en/docs/agents-and-tools/sub-agents) under `.claude/agents/`. Subagents are specialised reviewers Claude Code can delegate to when a task matches their description. Each agent is a single Markdown file with YAML frontmatter (`name`, `description`, `tools`, `model`) followed by a system prompt.

The agents in this repo mirror the review concerns enforced by this CLAUDE.md:

| Agent                                                                | When to invoke                                                                                                                                     |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`posix-reviewer`](.claude/agents/posix-reviewer.md)                 | Reviewing `*.sh` files under `scripts/` or `lib/` for POSIX compliance and shellcheck cleanliness.                                                 |
| [`cross-platform-auditor`](.claude/agents/cross-platform-auditor.md) | Auditing Linux ↔ macOS portability (`sed -i`, `mktemp`, `readlink`, `stat`, `date`, `grep -P`, `echo -e`, `xargs -r`, `/proc`, `/etc/os-release`). |
| [`symlink-validator`](.claude/agents/symlink-validator.md)           | Validating `scripts/setup/symlinks.conf` entries against real files in the repo and the parser in `.tests/check.sh`.                               |
| [`mise-tool-curator`](.claude/agents/mise-tool-curator.md)           | Adding or upgrading a tool in `configs/tools/mise/conf.d/` — category placement, version pinning, backend runtime prerequisites, profile gating.   |

### Invocation

Claude Code can dispatch a subagent automatically when its `description` matches the task, or explicitly when the user names it (e.g., "use the posix-reviewer agent"). All agents are read-only by default — `mise-tool-curator` is the only one with `Edit` in its tool list.

### Adding or modifying agents

1. Drop a new `<name>.md` file in `.claude/agents/`.
2. Frontmatter must include at minimum `name` and `description`. Keep the description specific — vague descriptions cause mis-routing.
3. Restrict `tools:` to the minimum the agent needs (Read/Grep/Glob/Bash for reviewers; add Edit/Write only when the agent must mutate files).
4. The agent's system prompt should reference and apply the proof policy and review hardening rules from this CLAUDE.md.

### Tracked vs. ignored

The repo `.gitignore` un-ignores `.claude/agents/*.md` (overriding the global `~/.gitignore` rule of `.claude/*`). `.claude/settings.local.json` and the `.claude/skills` symlink remain ignored — `settings.local.json` is per-machine and `skills` is wired up by the existing project skills setup.

## Cross-Platform Review Checklist

For every change, verify:

- behavior on Linux (Ubuntu/Debian as primary, Arch/Fedora/Alpine as secondary)
- behavior on macOS (Darwin)
- any tool dependencies are guarded with `command -v`
- any path assumptions are valid on both platforms
- `sed` usage avoids GNU-only flags (e.g., `-i` requires different syntax on macOS)
- `mktemp` usage is portable (`mktemp` without template on macOS creates files differently)
- `grep` flags used are POSIX-portable
- `stat`, `date`, `readlink` differences are handled

## Blast Radius Awareness

For every change, evaluate impact:

1. **Symlink changes** — affect every machine that runs `setup-symlinks.sh`. Test thoroughly.
2. **install.sh changes** — affect fresh installs AND re-runs. Must remain idempotent.
3. **Platform detection changes** — affect ALL scripts that source `platform.sh`. Regression risk is high.
4. **Zsh config changes** — affect every new shell session. A syntax error locks users out. Test with `zsh -n ~/.zshrc`.
5. **mise conf.d changes** — affect tool availability across profiles. Version pins affect reproducibility.
6. **CI workflow changes** — affect the entire validation pipeline. Test locally first.

Never remove a `|| true` guard on a non-critical sourcing operation.

## Review Hardening

You must behave like a strict reviewer of your own work.

1. If a script uses any bashism, reject it even if it "works on my machine."
2. Prefer correctness over convenience. A POSIX-compliant 5-line solution beats a 1-line bashism.
3. For every implementation claim, label it:
   - **proven**: verified by reading the actual file
   - **inferred**: likely true based on surrounding code patterns
   - **assumption**: requires manual testing or runtime verification
4. Do NOT claim a script is POSIX-compliant unless you have checked every construct against the rules.
5. If an approach only works on one platform, say so explicitly and provide the platform guard.
6. Distinguish clearly:
   - works on Ubuntu
   - works on macOS
   - works on all supported platforms
   - POSIX-portable
   - requires a specific tool or version
7. Be willing to split a "clean" unified approach into separate platform-specific implementations if correctness demands it.

## Proof Policy

For every important implementation claim, label it as one of:

- **proven from repo**: verified by reading the actual file in the repository
- **proven from runtime**: validated by executing the command or script
- **strong inference**: consistent with observed patterns, high confidence
- **assumption**: requires validation — state what validation is needed

Apply this especially to claims about:

- whether a tool is installed or available
- whether a script is sourced during the install flow
- whether a symlink target is active on a user's machine
- whether a mise tool version resolves and installs successfully
- whether a shellcheck rule passes
- whether macOS behavior matches Linux behavior for a given command

## Workflow for Non-Trivial Changes

### Phase 1 — Audit

Before any change, determine: affected files, current state (read them), platform detection patterns in use, install profile gating (`profile_includes`), symlink registry state, mise tool configuration state, test harness expectations. Classify findings as: proven, inferred, unknown.

### Phase 2 — POSIX Compliance Review

Check every construct in modified `.sh` files against the POSIX compliance table above. No exceptions.

### Phase 3 — Cross-Platform Review

Apply the cross-platform checklist above. Pay special attention to `sed -i`, `mktemp`, `readlink`, `stat`, and `date` differences.

### Phase 4 — Impact Analysis

List files to add/modify/remove, explain why, identify affected install profiles, symlinks.conf impact, test expectations, required vs optional changes, and rollback difficulty (trivial / moderate / requires manual intervention).

### Phase 5 — Implementation

Small, atomic changes. Follow existing patterns. Guard every external dependency. Ensure idempotency. No speculative abstractions. No scope creep.

### Phase 6 — Validation Plan

Specify: static validation (`shellcheck`), local validation steps, Docker test coverage, CI workflow coverage, what needs macOS testing.

### Phase 7 — Self Review

Actively try to find: POSIX violations, platform assumptions stated as universal, missing `command -v` guards, hardcoded paths, idempotency breaks, symlinks.conf errors, profile gating errors, test gaps, protected file violations, `sed -i` without macOS compat, missing error handling.

## Required Output Structure

For any non-trivial change, structure your response as:

### Audit

- Files read and their current state
- Relevant existing patterns identified
- Proof labels for key findings

### Impact Analysis

- Files to add / modify / remove
- Install profiles affected
- Symlink registry impact
- Test harness impact
- Rollback difficulty

### Implementation

- Exact code changes with rationale
- POSIX compliance verification for each `.sh` change
- Platform compatibility notes

### Validation Plan

- [ ] `shellcheck --shell=sh` passes on all modified `.sh` files
- [ ] `./scripts/utils/posix_check.sh` passes
- [ ] `.tests/run-all.sh` passes in Docker
- [ ] Change is idempotent (running twice produces same result)
- [ ] Cross-platform: [specify what needs macOS testing]

### Self Review

- What is strong about this change
- What is a known limitation or compromise
- What a skeptical reviewer should challenge
- What requires runtime verification

## Quality Bar

Your result must be:

- POSIX-compliant for all `.sh` files (proven, not claimed)
- cross-platform correct or explicitly platform-guarded
- idempotent and non-destructive
- consistent with existing codebase patterns
- small and reviewable
- honest about what you verified vs assumed

Do not:

- introduce bashisms and claim POSIX compliance
- assume macOS and Linux behave identically
- skip shellcheck validation
- modify protected files
- add complexity beyond what the change requires
- hide platform-specific behavior behind generic code
- claim cross-platform correctness without checking `sed`, `mktemp`, `stat`, `date`, `readlink` differences
