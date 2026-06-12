---
title: "Zsh interactive startup performance"
date: 2026-06-13
status: implemented
type: performance-study
platform: linux-ubuntu
audience: agents
summary: >
  Interactive zsh startup took 2.1-3.7s. Root cause: Ubuntu's /etc/zsh/zshrc
  runs compinit before .zshrc, causing the completion dump to be deleted and
  fully rebuilt on every shell start. Four secondary costs: an unconditional
  zcompile loop (441ms), `npm completion` spawning Node (222ms), a
  `docker compose version` daemon round-trip (85ms), and a futile
  `terraform -install-autocomplete` probe (84ms). Fixes target ~400ms.
affected_files:
  - configs/shell/zsh/.zshenv
  - configs/shell/zsh/_completions.zsh
  - configs/shell/zsh/aliases.d/20-docker.zsh
measurements:
  baseline_startup: "0.96-3.41s (zsh -i -c exit, isolated A/B harness)"
  after_skip_global_compinit_only: "1.23s (4 runs, stable)"
  after_all_fixes: "0.13s steady state (first run 0.69s builds caches)"
  zcompile_loop: "441ms (measured in isolation)"
  npm_completion: "222ms"
  docker_compose_probe: "85ms"
  terraform_probe: "84ms"
  mise_activate: "65ms (kept as-is, intentional)"
verification:
  - "zsh -n on all modified files"
  - "compdump mtime stable across consecutive shell starts"
  - "completion mappings present for docker/kubectl/terraform/vault/aws/npm"
  - "dc alias still defined"
  - "startup re-benchmarked after changes"
tags: [zsh, performance, startup, compinit, completions, antidote, mise]
---

## Context

Interactive shell startup (`zsh -i -c exit`) measured at **2.1–3.7 seconds**
on the primary Ubuntu machine. A healthy target for this config (antidote +
mise + cached completions) is **300–500ms**.

Profiling method:

1. `zprof` over a full `.zshrc` source — only accounted for ~270ms,
   proving the bulk of the time was spent in **external processes**, which
   zprof cannot see (it only profiles zsh functions).
2. Timestamped xtrace: `PS4=$'+%D{%s%6.}|%N:%i> ' zsh -xi -c exit`, then a
   gap analysis between consecutive trace lines to attribute wall-clock time
   to specific file:line locations.
3. Isolated timing of each suspect external command with `date +%s%N`.

## Findings (ranked by cost)

### 1. Completion dump churn — ~1–2.5s per shell (root cause)

Ubuntu's `/etc/zsh/zshrc` (line 111–112) runs `compinit` **before**
`~/.zshrc` executes, guarded only by the `skip_global_compinit` variable:

```sh
# /etc/zsh/zshrc (system file, not ours)
if (( ... ubuntu ... )) && [[ -z "$skip_global_compinit" ]]; then
  autoload -U compinit
  compinit
fi
```

This creates a feedback loop with our own completion bootstrap:

1. System `compinit` runs with the **base** fpath — our `~/.zsh/completions`
   dir and antidote plugin paths are not registered yet. It rewrites
   `~/.zcompdump` with only system completions.
2. `_completions.zsh` then greps the dump for our generated entries
   (`_glab`, `_docker`, `_kubectl`, …), finds them missing, **deletes the
   dump**, and runs a full `compinit` (security audit + dump + `zcompile -R`).
3. Next shell: goto 1. The dump never survives a single restart.

Verified at runtime: `~/.zcompdump` mtime changed after every shell start.

**Fix:** set `skip_global_compinit=1` in `.zshenv` (the escape hatch
documented inside `/etc/zsh/zshrc` itself). Our `_completions.zsh` is the
sole `compinit` owner and runs it with the complete fpath.

**Measured effect:** 2.1–3.7s → **1.23s** (stable across 4 runs), dump mtime
stable across runs.

Note for macOS: there is no `/etc/zsh/zshrc` compinit on Darwin; the variable
is simply inert there. Safe cross-platform.

### 2. Unconditional zcompile loop — 441ms

`_completions.zsh` byte-compiled **all** generated completion files on
**every** startup, regardless of freshness:

```zsh
for f in "$COMPDIR"/_*(N); do
  [[ -f "$f" && "$f" != *.zwc ]] && zcompile "$f" 2>/dev/null || true
done
```

`_deno` is 238KB and `_warp-cli` 193KB — recompiling those alone costs
~350ms. Measured loop total: **441ms**.

**Fix:** only compile when the source is newer than its `.zwc`:

```zsh
[[ ! -f "${f}.zwc" || "$f" -nt "${f}.zwc" ]] && zcompile "$f"
```

Steady-state cost drops to ~0ms (stat calls only).

### 3. `npm completion` spawns Node — 222ms

The bash-fallback section ran `eval 'source <(npm completion)'` on every
startup. `npm completion` boots a full Node process. Its output is static
for a given npm version.

**Fix:** cache the output to `$COMPDIR/npm-completion.zsh` via the existing
`_gen_comp_if_missing` helper and source the file. Regeneration follows the
same convention as every other generated completion (`ZSH_COMP_REFRESH=1`).

### 4. `docker compose version` daemon round-trip — 85ms

`aliases.d/20-docker.zsh` probed the compose plugin by actually running
`docker compose version` (CLI boot + plugin resolution) just to decide
whether `dc` means `docker-compose` or `docker compose`.

**Fix:** check for the compose CLI plugin file on disk instead
(`~/.docker/cli-plugins/docker-compose`, `/usr/libexec/docker/cli-plugins/`,
`/usr/lib/docker/cli-plugins/`, `/usr/local/lib/docker/cli-plugins/`).
File-existence tests are effectively free.

### 5. Futile `terraform -install-autocomplete` probe — 84ms

`_completions.zsh` ran `terraform -install-autocomplete zsh` on every
startup. This command errors once autocomplete is already installed, and the
file the success-branch looks for
(`~/.terraform.d/autocomplete/zsh_autocomplete`) is never created by
terraform — so the code always fell through to the bash-style
`complete -o nospace -C terraform terraform` anyway, after paying ~84ms.

**Fix:** drop the probe; register the bash-style completion directly.

### Kept as-is (deliberate)

- `mise activate zsh` (65ms at source + ~150ms `_mise_hook` at first
  prompt): the price of mise's env-aware mode. The shims-only alternative is
  faster but loses per-directory environment switching. Not changed.
- `antidote load` (~100ms): already static-loading from the cached bundle.
- Observation, not changed here: `atuin` and `zoxide` were not on `PATH` at
  the point `.zshrc` reaches their `command -v` guards (mise prepends tool
  paths at the first prompt hook), so their init lines can be silently
  skipped in fresh shells when the tools are only mise-managed.

## Results (post-implementation, measured)

Method: two isolated fake `$HOME` directories built from symlinks to the
real home (tools, caches, antidote) plus zsh config from either the original
checkout (`home-base`) or the fixed one (`home-fix`), each with a private
copy of `~/.zsh/completions` and its own `.zcompdump`. The live machine
config was never touched during testing. 5 runs of
`/usr/bin/time zsh -i -c exit` per side.

| Harness | Startup (5 runs) | compdump |
| --- | --- | --- |
| Baseline (original config) | 3.13, 3.08, 1.77, 1.09, 0.96s | rewritten on **every** run |
| Fixed (all 5 changes) | 0.13, 0.13, 0.14, 0.13, 0.13s | stable across 10+ runs |

First run on a machine after the change is ~0.7s (builds the dump and the
npm completion cache once), then steady-state **~130ms** — a **7–25x**
improvement. Real-world steady state will be slightly higher in shells where
mise-managed tools are on `PATH` at startup (tmux-nested shells), since the
gcloud/vault/aws bash-fallback registrations then run; the npm cache saves
its 222ms there.

### Regression found and fixed during validation

Disabling the system compinit exposed a latent ordering bug:
`functions.d/60-zsh-utils.zsh` called `compdef _mr_completion mr` at file
scope, which only worked because Ubuntu's early compinit had already defined
`compdef` by the time `functions.d` loaded. With `skip_global_compinit=1`
this produced `command not found: compdef` on startup and the `mr`
completion silently fell back to the plugin's `_myrepos`.

Fix: `60-zsh-utils.zsh` queues the registration in a `_deferred_compdefs`
array when `compdef` does not exist yet; `_completions.zsh` replays the
queue immediately after `compinit`. Verified: `_comps[mr]` maps to
`_mr_completion` again, zero stderr on startup.

### Regression matrix (baseline vs fixed — identical)

Checked in both harnesses, `diff` of outputs empty: `dc`/`d` aliases,
fast-syntax-highlighting loaded, history-substring-search widgets bound,
git-open function, `_comps` mappings for docker/kubectl/glab/helm/gh/mise/mr,
theme `PROMPT` rendered, `functions.d` loaders (`update`, `zreset`).

Static checks: `zsh -n` passes on all modified files; shellcheck finding
counts unchanged vs originals (new zsh-isms carry targeted
`# shellcheck disable` directives, matching existing file conventions).

## Reproduction commands

```sh
# Wall-clock startup
/usr/bin/time -f "%e s" zsh -i -c exit

# Function-level profile (zsh functions only — misses subprocesses)
zsh -i -c 'zmodload zsh/zprof; source ~/.zshrc >/dev/null 2>&1; zprof'

# Subprocess-level attribution
PS4=$'+%D{%s%6.}|%N:%i> ' zsh -xi -c exit 2>/tmp/trace.log
# then gap-analyze consecutive timestamps in /tmp/trace.log

# Dump churn check (mtime must NOT change between runs)
stat -c '%Y' ~/.zcompdump; zsh -i -c exit; stat -c '%Y' ~/.zcompdump
```
