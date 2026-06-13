---
title: "Rust efficiency opportunities in dotfiles"
date: 2026-06-13
status: proposed
type: feasibility-study
platform: multi-platform
audience: maintainers
summary: >
  Most installer and symlink logic is dominated by package manager, network, or
  filesystem latency, so rewriting it in Rust would add bootstrap complexity
  with little benefit. The only clear candidate for a small Rust helper is
  `scripts/utils/mise-update-pins.sh`, which does parsing-heavy TOML scanning,
  fans out many `mise latest` subprocesses, and rewrites version pins with
  fragile text substitution. A second-tier candidate is the interactive `update`
  orchestrator, but most of its wall time comes from external tools rather than
  shell overhead.
affected_files:
  - scripts/utils/mise-update-pins.sh
  - configs/shell/zsh/functions.d/80-update.zsh
  - scripts/setup/generate-keybindings.sh
  - scripts/setup/setup-symlinks.sh
  - scripts/utils/platform.sh
  - docs/studies/2026-06-13-zsh-startup-performance.md
tags: [rust, performance, shell, mise, zsh, study]
---

## Question

Could part of this repository be converted to a **simple Rust program** to gain
meaningful efficiency?

## Short answer

Yes, but only in a narrow slice of the repo.

- **Best candidate:** `scripts/utils/mise-update-pins.sh`
- **Possible but lower-value candidate:** `configs/shell/zsh/functions.d/80-update.zsh`
- **Not worth converting:** installer, symlink setup, platform detection, and
  most startup config

## Audit

### Files reviewed

- `scripts/utils/mise-update-pins.sh`
- `configs/shell/zsh/functions.d/80-update.zsh`
- `scripts/setup/generate-keybindings.sh`
- `scripts/setup/setup-symlinks.sh`
- `scripts/utils/platform.sh`
- `.tests/check.sh`
- `docs/studies/2026-06-13-zsh-startup-performance.md`

### Key findings

1. **`mise-update-pins.sh` is parsing-heavy and text-rewrite-heavy**  
   **proven from repo:** it parses TOML with `awk`, fans out background
   `mise latest` jobs, collects temp files, and rewrites versions with
   `grep` + `sed -i`.

2. **`update` is an orchestration wrapper around expensive external tools**  
   **proven from repo:** it mostly delegates to `apt`, `git pull`, `nvim`,
   `mise`, `krew`, and `compinit`.

3. **The install path is not shell-CPU-bound**  
   **proven from repo:** `install.sh`, `setup-symlinks.sh`, and `.tests/check.sh`
   mostly perform filesystem work or invoke package managers.

4. **Interactive zsh startup is already optimized in shell**  
   **proven from repo:** the existing startup study reports steady-state startup
   around `~130ms` after shell-level fixes, which removes the strongest case for
   a Rust startup helper.

## Candidate ranking

### 1. `scripts/utils/mise-update-pins.sh` — strong Rust candidate

Why it fits:

- Parses TOML with ad-hoc `awk` rules
- Spawns one `mise latest` subprocess per tool
- Uses temp files as a job/result transport
- Rewrites TOML with line-oriented `sed` substitutions
- Is a user-facing maintenance tool, not a one-shot bootstrap step

What Rust would improve:

- Real TOML parsing instead of regex/string parsing
- Structured file rewriting instead of fragile `sed -i`
- Simpler concurrent `mise latest` execution and result collection
- Better error reporting for malformed config or ambiguous edits

Expected benefit:

- **strong inference:** lower CPU overhead and lower maintenance risk
- **strong inference:** modest wall-clock win, but bigger correctness win than
  raw speed win because network/registry queries still dominate total runtime

Recommended scope:

- Build one small helper that:
  1. reads `configs/tools/mise/conf.d/*.toml`
  2. extracts `[tools]` entries
  3. queries `mise latest`
  4. prints a report or rewrites pins atomically

Why this is still reasonable in this repo:

- It is optional developer tooling, not required for first bootstrap
- A shell fallback can remain for environments without the binary

### 2. `configs/shell/zsh/functions.d/80-update.zsh` — maybe, but probably not first

Why it is less attractive:

- Most time is spent inside external commands, not in zsh control flow
- A Rust rewrite would still need to shell out to `apt`, `git`, `nvim`, `mise`,
  and `krew`
- Parallel execution is the real opportunity, and shell can already do that

Where Rust could help:

- Better concurrent orchestration
- Cleaner progress/error aggregation
- More robust summary reporting

Why shell may be enough:

- Running independent steps in background jobs would likely capture most of the
  benefit without adding a new compiled dependency

### 3. `scripts/setup/generate-keybindings.sh` — not worth it

Why not:

- Small script
- Infrequent execution
- Very little data
- Current work is simple string transformation

Expected gain:

- **strong inference:** negligible in real usage

### 4. `scripts/setup/setup-symlinks.sh` — not worth it

Why not:

- Dominated by `mkdir`, `mv`, and `ln -s`
- Real cost is filesystem I/O, not shell parsing
- Runs rarely enough that startup/toolchain cost would outweigh savings

### 5. `scripts/utils/platform.sh` and installer path — not worth it

Why not:

- Platform detection is tiny
- Installer runtime is dominated by package downloads, git clones, and tool
  installs
- Replacing the bootstrap layer with Rust would make initial setup harder,
  especially on fresh machines where Rust is not yet present

## Where Rust should **not** be used

### Zsh startup

The existing startup study already found and fixed the expensive parts in shell:

- global `compinit` churn
- unconditional `zcompile`
- uncached `npm completion`
- expensive Docker/Terraform probes

With steady-state startup already near `130ms`, a Rust helper would add
complexity for very limited upside.

## Recommendation

### Recommended path

1. **Do not rewrite the installer/bootstrap path in Rust**
2. **If you want one Rust experiment, make it `mise-update-pins`**
3. Keep the shell wrapper and call the Rust binary only when available
4. Re-measure before expanding the Rust footprint

### Suggested acceptance bar for a Rust helper

Only keep it if it delivers at least one of these:

- materially simpler logic than the shell version
- safer config parsing/editing
- clearly faster execution on a realistic tool set
- no regression to Linux/macOS bootstrap simplicity

## Conclusion

This repo does **not** have a broad “rewrite shell in Rust” opportunity.
Its performance-sensitive shell startup path has already been optimized, and its
installer path is mostly waiting on external systems.

The one area where a small Rust program makes sense is
`scripts/utils/mise-update-pins.sh`, because it combines:

- structured config parsing
- concurrent subprocess orchestration
- atomic file rewriting
- repeat developer usage

If you want to try Rust here, start there and keep everything else in shell.
