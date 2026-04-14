# add-mise-tool

Add, update, or remove tools managed by mise in this dotfiles repository.

## When to use

Use when the user wants to add a new tool via mise
("add ripgrep", "install lazygit", "add terraform"),
bump a tool version ("update bat", "bump node"),
or remove a tool from mise management.
Also use when the user asks which category a tool belongs in
or how to pin a version.

## How mise tools are organized

Tools live in `configs/tools/mise/conf.d/` as numbered TOML files,
each covering a category:

| File                      | Category            | Profile-gated? |
| ------------------------- | ------------------- | -------------- |
| `01-languages.toml`       | Runtime languages   | No             |
| `02-essentials.toml`      | Core CLI tools      | No             |
| `03-infra.toml`           | Infrastructure      | Yes            |
| `04-containers.toml`      | Container tooling   | Yes            |
| `05-dev-tools.toml`       | Dev utilities       | No             |
| `06-linters.toml`         | Linting/formatting  | No             |
| `07-git-vcs.toml`         | Git extensions/VCS  | No             |
| `08-observability.toml`   | Monitoring          | Yes            |
| `09-offensive-stuff.toml` | Security/pentesting | Yes            |

The root `mise.toml` at the repo root pins only orchestration tools
(hk, pkl, prettier, shellcheck). Application tools go in `conf.d/`.

## Steps

### Adding a new tool

1. **Identify the correct category file.** Match the tool's purpose
   to a category above. When in doubt, `05-dev-tools.toml` is the
   catch-all for general utilities.

2. **Determine the backend syntax.** Mise supports multiple backends:
   - **Native** (most common): `tool-name = "version"`
   - **Cargo backend**: `"cargo:crate-name" = "version"`
   - **NPM backend**: `"npm:package-name" = "version"`
   - **Go backend**: `"go:import-path" = "version"`
   - **Pipx backend**: `"pipx:package-name" = "version"`

3. **Check backend prerequisites.** If using `cargo:`, `npm:`,
   `go:`, or `pipx:`, verify the parent runtime exists in
   `01-languages.toml`:
   - `cargo:` needs `rust`
   - `npm:` needs `node`
   - `go:` needs `go`
   - `pipx:` needs `python` or `pipx` (in `05-dev-tools.toml`)

   Read `01-languages.toml` to confirm. If the runtime is missing
   or commented out, flag this — the tool will fail to install.

4. **Find the correct version to pin.** Use
   `mise ls-remote <tool-name>` to list available versions, or check
   the tool's GitHub releases. Never use `latest` in conf.d files —
   always pin a specific semver version.

5. **Add the entry** to the `[tools]` section of the chosen file.
   Place it in a logical position:
   - If there are comment-delimited subsections
     (like in `03-infra.toml`), place under the right subsection
   - Otherwise, group with similar tools
     (e.g., cargo-based tools together)
   - Add an inline comment if the binary name differs from the
     tool name (e.g., `"cargo:bottom" = "0.12.3" # use btm`)

6. **Verify the install works:**

   ```sh
   mise install
   mise x -- <tool-name> --version
   ```

### Bumping a tool version

1. **Find the tool** — grep across
   `configs/tools/mise/conf.d/*.toml` and the root `mise.toml`.
2. **Check the latest version** —
   use `mise ls-remote <tool-name> | tail -5` or check GitHub.
3. **Update the version string** in place.
4. **Verify:** `mise install && mise x -- <tool-name> --version`

### Removing a tool

1. **Find the tool** in the conf.d files.
2. **Comment it out** (preferred for temporary removal)
   or delete the line.
3. **Run `mise prune`** to clean up unused versions.

## Important rules

- **Never use `latest`** in conf.d files.
  The root `mise.toml` is the only exception.
- **Always pin specific versions** — reproducibility across
  machines depends on this.
- **Respect profile gating.** Files `03`, `04`, `08`, `09` are
  excluded from the default install profile. Tools that most users
  need should NOT go in these files. If a tool belongs in a gated
  file, mention that it requires `--full` install.
- **Check backends have their runtime.** A `cargo:` tool with no
  `rust` in `01-languages.toml` will fail silently during install.
- **Don't add tools to the root `mise.toml`** unless they're
  needed for repo-level tasks (linting, hooks).
  Application tools belong in `conf.d/`.
- After adding tools, `mise install` must succeed.
  If it doesn't, the version or backend is wrong.
