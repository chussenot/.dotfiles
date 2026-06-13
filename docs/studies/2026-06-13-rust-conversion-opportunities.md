---
title: "Rust conversion opportunities for efficiency"
date: 2026-06-13
status: proposed
type: architecture-study
platform: linux-ubuntu
audience: agents
summary: >
  Most installer and setup scripts are too infrequent and already too fast to
  justify a Rust rewrite. The only strong efficiency candidate is the zsh
  prompt theme, which shells out to many external commands on every prompt
  render. `_completions.zsh` is a secondary candidate only for cache bookkeeping;
  its expensive work is still dominated by external CLI completion generators.
affected_files:
  - configs/shell/chussenot.zsh-theme
  - configs/shell/zsh/_completions.zsh
  - scripts/setup/setup-symlinks.sh
  - scripts/setup/generate-keybindings.sh
  - scripts/utils/backup.sh
  - scripts/utils/platform.sh
  - scripts/utils/mise-update-pins.sh
  - .tests/check.sh
measurements:
  generate_keybindings: "~10ms average over 5 runs"
  setup_symlinks: "~172ms average over 5 runs in isolated HOME"
  backup_script: "~11ms average over 5 runs in isolated HOME"
  platform_detect: "~5.4ms per call (~5.37s / 1000 calls)"
verification:
  - "Read installer, setup, backup, platform, completion, prompt, and validation scripts"
  - "Benchmarked representative scripts in isolated temporary HOME directories"
  - "Verified shell lint workflow command in .github/workflows/lint.yml"
tags: [rust, performance, shell, zsh, prompt, setup, bootstrap]
---

## Executive summary

Yes, **one part of the dotfiles is a credible Rust candidate**: the **zsh prompt
theme** in `configs/shell/chussenot.zsh-theme`.

Everything else I reviewed falls into one of these buckets:

1. **Too infrequent** to matter (`install.sh`, package installation, backup,
   symlink setup, keybinding generation).
2. **Already cheap** (roughly 10-170ms total per run for the small local
   scripts I benchmarked).
3. **Dominated by external tools or network/package-manager work**, so Rust
   would mostly move orchestration around rather than remove the real cost.

## Method

I reviewed the current implementation paths that matter for user-visible
latency:

- interactive shell startup
- prompt rendering
- install/setup scripts
- maintenance scripts

I also ran isolated benchmarks for the local shell scripts that can be measured
safely without touching the real home directory:

| Area | Result |
| --- | --- |
| `generate-keybindings.sh` | ~10ms average |
| `backup.sh` | ~11ms average |
| `setup-symlinks.sh` | ~172ms average |
| `platform_detect` | ~5.4ms per call |

Those numbers are already small, and all of those paths are one-shot or rare.

## Findings by area

### 1. Prompt rendering is the best Rust target

**Status:** recommended candidate

`configs/shell/chussenot.zsh-theme` does a lot of work on every prompt render:

- git repository detection and branch lookup
- git dirty-state checks
- `python3 --version`
- `node --version`
- `go version`
- `rustc --version`
- `uptime` parsing
- `bc` for load comparisons
- optional `docker info`

This is the one place where the repo repeatedly pays process startup cost during
normal interactive use. The current implementation is also shell-pipeline heavy
(`sed`, `awk`, `tr`, `wc`, multiple `git` invocations).

### Why Rust fits here

- The path is **hot**: every prompt, not just install time.
- The work is mostly **local parsing and aggregation**, which Rust can do
  cheaply.
- A small helper could replace many short-lived subprocesses with one call.
- The helper can emit a simple shell-neutral format (plain text or key/value
  pairs), leaving zsh responsible only for styling.

### Constraints

- The binary must be **optional** on first boot and in the `--minimal` profile.
  Today, the repo boots from POSIX shell before mise installs Rust-managed
  tools.
- A prompt helper should therefore degrade cleanly when absent.
- This helper would need Linux/macOS support without introducing a mandatory
  compile step during bootstrap.

### Recommendation

If you want one Rust program in this repo for performance, make it a **single
prompt metadata helper** and keep all installer/setup logic in shell.

## 2. `_completions.zsh` is only a partial Rust candidate

**Status:** maybe, but not first

`configs/shell/zsh/_completions.zsh` already received a targeted performance
pass, and the existing study shows
steady-state startup around **~130ms** after the fixes.

The important detail is that this file's expensive work is mostly:

- invoking external CLIs to generate completions
- running `compinit`
- sourcing bash-style completion fragments when tools do not ship native zsh
  completions

Rust cannot materially accelerate `docker completion zsh`,
`kubectl completion zsh`, `gh completion`, `npm completion`, or `compinit`.
Those commands remain the cost center.

### Where Rust could help a little

A helper could centralize:

- cache-manifest checks
- freshness tracking
- completion inventory bookkeeping

But that is a **secondary optimization**. The shell code is not the main
bottleneck anymore.

### Recommendation

Do not rewrite `_completions.zsh` in Rust unless you first re-measure startup
and prove that the remaining cost is in your own shell bookkeeping rather than
the external completion generators.

## 3. Symlink setup is not worth moving to Rust

**Status:** not recommended

`scripts/setup/setup-symlinks.sh` and `.tests/check.sh` both parse
`scripts/setup/symlinks.conf`.

That duplication is real, but the runtime cost is small:

- 32 registry entries
- ~172ms average for the full setup script in an isolated home directory

This path also runs infrequently. A Rust rewrite would add packaging and
bootstrap complexity for a cost that is already below human-noticeable
thresholds.

### Better direction

If you want to improve this area, reduce duplicate parsing logic or tighten the
shell implementation. Do not introduce Rust just for speed.

## 4. Backup and keybinding generation are already fast

**Status:** not recommended

- `scripts/utils/backup.sh`: ~11ms average in the benchmark
- `scripts/setup/generate-keybindings.sh`: ~10ms average in the benchmark

These are tiny local transformations. Rust would not produce a meaningful
user-visible win here.

## 5. Platform detection and installer orchestration should stay shell

**Status:** not recommended

`platform_detect` is small and portable, but more importantly it is not on a
hot path:

- about ~5.4ms per call in the benchmark
- invoked during install/setup flows, not during every shell interaction

More broadly, `install.sh` and `install-packages.sh` are dominated by:

- package-manager latency
- filesystem work
- network operations
- privilege escalation

Rust would not accelerate the expensive parts. It would mostly make bootstrap
harder in a repository whose current contract is: **POSIX shell first, tools
later**.

## 6. `mise-update-pins.sh` is heavy, but not for reasons Rust solves

**Status:** not recommended

`scripts/utils/mise-update-pins.sh` does substantial work, but the expensive
part is querying remote registries via
`mise latest`. The script already parallelizes those checks.

That makes it a poor Rust target:

- it is maintenance-time, not interactive-time
- network/registry latency dominates
- the current shell overhead is not the main problem

## Recommendation matrix

| Area | Frequency | Current bottleneck | Rust fit | Verdict |
| --- | --- | --- | --- | --- |
| `chussenot.zsh-theme` | every prompt | many short-lived subprocesses | high | **yes** |
| `_completions.zsh` | every shell startup | external completion generators + `compinit` | medium-low | maybe later |
| `setup-symlinks.sh` | occasional | light filesystem work | low | no |
| `.tests/check.sh` symlink checks | occasional | light filesystem work | low | no |
| `backup.sh` | occasional | tiny local copies | low | no |
| `generate-keybindings.sh` | rare | tiny text generation | low | no |
| `platform.sh` | install/setup only | tiny parsing | low | no |
| `install*.sh` | rare | package manager + network | low | no |
| `mise-update-pins.sh` | maintenance only | remote registry calls | low | no |

## Practical conclusion

If the goal is **real efficiency gain with minimal architectural churn**:

1. **Do build a Rust helper for prompt metadata** if you want to experiment.
2. **Do not** rewrite installer/setup scripts in Rust for performance reasons.
3. **Do not** rewrite `_completions.zsh` unless fresh measurements show the
   remaining startup cost is mostly your own bookkeeping.

So the answer is: **yes, but only narrowly**. A small Rust program can make
sense for the prompt path; most of the rest of this repository should stay in
portable shell because the measurable payoff is too small.
