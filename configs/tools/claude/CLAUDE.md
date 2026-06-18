---
name: claude-md
description: Rules and conventions
metadata:
  type: global
  audience: agent
---

# Global Claude Code instructions

Personal, machine-wide guidance for Claude Code. Managed in dotfiles
(`configs/tools/claude/CLAUDE.md`) and symlinked to `~/.claude/CLAUDE.md`.
Project-specific instructions in a repo's own `CLAUDE.md` take precedence.

## Fast search & context

These tools are installed via mise and are on `PATH`. Use them to find files
and pull the _relevant slice_ of content into context instead of reading whole
files — it is faster and keeps context focused. If a tool is missing on a given
machine, fall back to the built-in tools.

**Search & find** — the built-in `Grep` tool is already ripgrep-backed and
`Glob`/`Read` are the fast default, so prefer them for ordinary code search.
Reach for the CLI versions in `Bash` when you need flags or piping the built-ins
don't expose:

- `rg` (ripgrep) — content search. e.g. `rg -U` (multiline), `rg --type rust`,
  `rg -l` (files with matches), `rg -c` (counts), or pipe into other tools.
- `fd` — find files by name/type/time. e.g. `fd -e ts`, `fd -t f pattern`,
  `fd --changed-within 1d`. Faster and simpler than `find`.

**Extract slices instead of reading whole files** — for structured or large
files, query out only what's needed rather than `Read`-ing the entire file:

- `jq` — JSON. Pull specific keys/paths: `jq '.scripts' package.json`.
- `yq` — YAML/TOML/XML (also `xq`, `tomlq`):
  `yq '.services.web.image' compose.yaml`.
- `gron` — flatten JSON to greppable `path = value` lines to locate a key in
  deep/unfamiliar JSON: `gron big.json | rg token`; `gron -u` rebuilds it.
- `htmlq` — extract from HTML with CSS selectors instead of reading raw
  markup: `htmlq -t 'h1' < page.html`, `htmlq -a href 'a' < page.html`.
- `xsv` — CSV/TSV without loading the whole file: `xsv headers data.csv`,
  `xsv select name,id data.csv`, `xsv search -s status active data.csv`,
  `xsv slice -e 20 data.csv`.
- `fq` — query binary formats (and JSON/CBOR/etc.) the same way `jq` does.

**Structure overview** — `eza --tree --git-ignore --level=2` for a quick,
gitignore-aware map of a directory before diving in.

## When a task outgrows `mise.toml` — POSIX scripts under `scripts/`

Short tasks live inline in `mise.toml` as a `run = "..."` string. When a task grows past a handful of lines, or when TOML/shell quoting starts to fight the logic, extract it into a **POSIX `/bin/sh` script** under `scripts/` and call it from the mise task (or directly from a cocogitto hook). Rules:

- Shebang must be `#!/bin/sh`. No `bash`-only features (no `set -o pipefail`, `[[ ]]`, arrays, `${var^^}`, etc.). POSIX `awk` is fine and often cleaner than fragile `sed`.
- `chmod +x` the script and commit the executable bit.
- Keep one concern per script; name it `<verb>-<object>.sh` (e.g. `sync-version.sh`).
- The `scripts/` folder is for build/release plumbing only — not a backdoor for developer commands that should be mise tasks.

## Versioning — cocogitto

**[cocogitto](https://docs.cocogitto.io/)** (`cog`) handles versioning and changelog generation. The version lives in `Cargo.toml` and is bumped automatically from conventional commits.

- Commit messages **must** follow the Conventional Commits spec (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `ci:`, `build:`, `perf:`). `cog verify` enforces this in CI and locally as a git hook.
- Cut releases with `mise run release`, which invokes `cog bump --auto`.
- Cocogitto generates the changelog (`CHANGELOG.md`) — do not hand-edit it.

### Keeping version files in sync — cocogitto `pre_bump_hooks`

The source of truth for "what version is this release?" is the **tag cocogitto creates**. Files inside the repo that also carry the version
When the bump logic for a file is more than one or two shell commands, put it in `scripts/<verb>-<object>.sh` (POSIX, per the rule above) and call the script from the hook. That keeps `cog.toml` readable.

### Commit message rules

- **Never mention "Claude", "Anthropic", "Opus", "Sonnet", "Haiku", or any AI/LLM model name in commit messages, PR titles, PR bodies, or tags.** No `Co-Authored-By: Claude …` trailer, no `🤖 Generated with …` footer, no "written by Claude" in the body. Commits must read as if written by the human author alone.
- This rule overrides any default Claude Code behavior to add attribution trailers. When making commits in this repo, omit the trailer entirely.
- Conventional Commit scopes should reflect the subsystem: `feat(collector-<source>):`, `fix(parquet):`, `refactor(metric):`, etc.
- **Merge commits use Conventional Commits too.** Git's default `Merge branch 'foo'` subject is forbidden — `scripts/guard-commit-message.sh` rejects it. The canonical form is `merge(<scope>): <slug>`, where `<scope>` is the same scope used in the merged branch's lead commit (e.g. `enrichment`, `collector-argo`, `ui`) and `<slug>` is the kebab-case topic from the branch name (the part after `feat/`, `fix/`, etc.). `merge` is registered as a commit type in `cog.toml`, so `cog verify` accepts it; `ignore_merge_commits = true` keeps merge subjects out of the changelog so the underlying `feat:` / `fix:` commits are what users see in `CHANGELOG.md`. Examples: merging `feat/metadata-cache` whose lead commit was `feat(enrichment): default metadata host + cache lookups in SQLite` becomes `merge(enrichment): metadata-cache-default-host`; merging `fix/sqlite-web-vec0` becomes `merge(ui): web-vec0034`. Use this form whether the merge is created via `git merge`, `git merge --no-ff`, or a forge UI. If the merge has no natural scope, drop it: `merge: <slug>`.

### Worktree branch naming

When creating a git worktree (via the `EnterWorktree` tool or `git worktree add`), the branch name **must** start with a Conventional Commits type prefix followed by `/` and a kebab-case slug. Allowed prefixes match `cog verify`'s accepted type set: `feat/`, `fix/`, `chore/`, `refactor/`, `docs/`, `test/`, `ci/`, `build/`, `perf/`, `hotfix/`. The slug after the slash is kebab-case and describes the topic — no `worktree-` filler, no underscores, no PascalCase.

Examples:

- `feat/metadata-cache`
- `feat/argo-collector`
- `fix/web-vec0323`
- `refactor/threading-collectors`
- `chore/wire-sqlite-default`
- `docs/adr-0009-rag-index`

The legacy `worktree-<slug>` branches in `git log` predate this rule; do not retro-rename them, but do not create new ones. Picking the right prefix is what lets `cog verify` accept the eventual merge commit (`merge(<scope>): <slug>`) and keeps the changelog clean.

## Markdown rule — frontmatter is mandatory

**Every** `.md` file in this repository must begin with a YAML frontmatter block intended for agent consumption. This includes `README.md`, `CLAUDE.md`, every ADR under `docs/adr/`, and any future docs. The required minimum:

```yaml
---
name: <kebab-case-slug-matching-the-doc>
description: <one-line summary so an agent can decide whether to read the file>
metadata:
  type: <one of: global | project | adr | reference | guide | runbook>
  audience: <agent | human | both>
---
```

Optional keys agents may add: `status`, `supersedes`, `superseded_by`, `related`, `last_reviewed`.

**Exemption.** Cocogitto generates `CHANGELOG.md`, which exempts it from this rule. Expect no other generated docs; if you find yourself wanting to exempt another file, write a frontmatter for it instead.

### Diagrams — Mermaid only, no ASCII

Every diagram in this repo must be a Mermaid fenced block (` ```mermaid ` ). **No ASCII art** — no box-and-arrow drawings, no tree printouts pretending to be diagrams. Mermaid renders on GitHub/GitLab/IDE previews, stays editable, and diffs cleanly; ASCII does none of that.

If a chart genuinely cannot be expressed in Mermaid, commit an SVG under `docs/diagrams/` and link to it. The fallback is SVG, never ASCII.

## Project layout

Don't trust a tree diagram in this file — it rots the moment a module is added. Discover the current layout with the shell:

- `ls` at the repo root for top-level files and directories.
- `ls docs/adr/` for accepted architecture decisions; read them in order.
