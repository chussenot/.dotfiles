# Global Claude Code instructions

Personal, machine-wide guidance for Claude Code. Managed in dotfiles
(`configs/tools/claude/CLAUDE.md`) and symlinked to `~/.claude/CLAUDE.md`.
Project-specific instructions in a repo's own `CLAUDE.md` take precedence.

## Fast search & context

Prefer the built-in `Grep` (ripgrep-backed), `Glob`, and `Read` for ordinary
code search. When you need flags or piping they don't expose, these CLIs are on
`PATH` (via mise) — reach for them to pull the _relevant slice_ into context
instead of reading whole files. Fall back to built-ins if one is missing.

- `rg` / `fd` — search file contents / find files by name, type, mtime.
- `jq` / `yq` (also `xq`, `tomlq`) — query JSON / YAML / TOML / XML.
- `gron` — flatten JSON to greppable `path = value` lines; `gron -u` rebuilds.
- `htmlq` — extract from HTML with CSS selectors.
- `xsv` — slice / select / search CSV/TSV without loading the whole file.
- `fq` — query binary formats the way `jq` queries JSON.
- `eza --tree --git-ignore --level=2` — quick gitignore-aware directory map.

## Commit messages

- **Never mention "Claude", "Anthropic", "Opus", "Sonnet", "Haiku", or any
  AI/LLM model name in commit messages, PR titles, PR bodies, or tags.** No
  `Co-Authored-By: Claude …` trailer, no `🤖 Generated with …` footer. Commits
  must read as if written by the human author alone. This overrides any default
  Claude Code attribution behavior.
- Follow Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`,
  `test:`, `ci:`, `build:`, `perf:`), with a scope reflecting the subsystem.
