# posix-check

Validate POSIX compliance of shell scripts in this
dotfiles repository.

## When to use

Use when the user asks to check POSIX compliance, lint shell
scripts, or before committing changes to `*.sh` files in
`scripts/` or `lib/`.

## Steps

1. Identify which shell scripts were changed or should
   be checked:
   - If the user specifies files, check those.
   - If no files specified, use `git diff --name-only HEAD`
     to find changed `.sh` files, falling back to all `.sh`
     files in `scripts/` and `lib/`.

2. For each `.sh` file (excluding `configs/` directory), verify:
   - **Shebang**: Must be `#!/bin/sh`
     (not `#!/bin/bash` or `#!/bin/zsh`)
   - **Brackets**: Uses `[ ]` not `[[ ]]`
   - **Functions**: Uses `name() {}` not `function name`
   - **No arrays**: No bash-style arrays
     (use space-separated strings)
   - **Arithmetic**: Uses `$(( ))` not `(( ))`
   - **No `local`**: Uses `_underscore_prefixed` variable
     names instead of `local`
   - **Redirects**: Uses `>/dev/null 2>&1` not `&>`

3. Run `shellcheck --shell=sh` on each file and report results.

4. Summarize findings: list passing files, failing files with
   specific violations, and suggested fixes for each violation.

## Important rules

- Files inside `configs/` (especially `*.zsh`) are exempt —
  they may use Zsh features.
- The `fzf.bash` and `fzf.zsh` files in
  `configs/shell/fzf/` are auto-generated and must NOT
  be modified.
- All fixes must preserve the existing code style: 2-space
  indentation, snake_case functions, kebab-case filenames.
