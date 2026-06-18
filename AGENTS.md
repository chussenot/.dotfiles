# AGENTS.md

Short, tool-agnostic entrypoint for AI coding agents. **Claude Code: read
`CLAUDE.md`** — it is the deeper, Claude-specific source of truth (skills,
subagents, hooks, proof policy, full POSIX table). This file is the portable
summary other agents can rely on.

## What this is

Multi-platform POSIX dotfiles (Linux primary — Ubuntu/Debian; macOS secondary).
Config lives in `configs/`; install and setup logic in `scripts/` and `lib/`.

## Operating rules (non-negotiable)

- Scripts in `scripts/` and `lib/` are strict POSIX `#!/bin/sh` — no bashisms
  (`[[ ]]`, `local`, arrays, `(( ))`, `&>`, `function`). Only `configs/**/*.zsh`
  may use Zsh features.
- Never run the installer as root. The install flow must stay idempotent.
- Never edit the protected fzf files: `configs/shell/fzf/fzf.bash`, `fzf.zsh`.
- `scripts/setup/symlinks.conf` is the symlink source of truth
  (`source_relative|${HOME}/target`). Verify the source exists before adding an
  entry; do not change the format — `.tests/check.sh` parses it.
- Use `${HOME}` / `${DOTFILES_DIR}`, never a hardcoded `/home/<user>`. Guard
  every external tool with `command -v`.
- New scripts must source `scripts/utils/platform.sh` and call
  `platform_detect` before using `is_linux` / `is_macos` / `install_pkg`.

## Verify before claiming done

| Command                                 | Checks                          |
| --------------------------------------- | ------------------------------- |
| `shellcheck --shell=sh <file>`          | every changed `.sh`             |
| `./scripts/utils/posix_check.sh`        | full POSIX scan                 |
| `mise run prelint && mise run postlint` | format + lint gate              |
| `./.tests/run-all.sh`                   | Docker integration tests (real) |

## Scope & continuity

- One change at a time. State its blast radius — symlinks, `install.sh`,
  `platform.sh`, and Zsh config all have wide reach (see CLAUDE.md "Blast Radius
  Awareness").
- Session continuity lives in `.remember/` (narrative log). Write your
  end-of-session handoff to `.remember/remember.md`.

Full rules, proof policy, and the skills/agents/hooks map: **`CLAUDE.md`**.
