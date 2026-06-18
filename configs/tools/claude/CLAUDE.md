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
- `yq` — YAML/TOML/XML (also `xq`, `tomlq`): `yq '.services.web.image' compose.yaml`.
- `gron` — flatten JSON to greppable `path = value` lines to locate a key in
  deep/unfamiliar JSON: `gron big.json | rg token`; `gron -u` rebuilds it.
- `htmlq` — extract from HTML with CSS selectors instead of reading raw markup:
  `htmlq -t 'h1' < page.html`, `htmlq -a href 'a' < page.html`.
- `xsv` — CSV/TSV without loading the whole file: `xsv headers data.csv`,
  `xsv select name,id data.csv`, `xsv search -s status active data.csv`,
  `xsv slice -e 20 data.csv`.
- `fq` — query binary formats (and JSON/CBOR/etc.) the same way `jq` does.

**Structure overview** — `eza --tree --git-ignore --level=2` for a quick,
gitignore-aware map of a directory before diving in.
