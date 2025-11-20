# --- Fast Zsh completions bootstrap -----------------------------------------
# Goal: generate once, then load fast on every shell start

# Directory to store generated completion files
COMPDIR="${ZDOTDIR:-$HOME}/.zsh/completions"
# Create directory with error handling
if ! mkdir -p "$COMPDIR" 2>/dev/null; then
  echo "⚠️  Warning: Could not create completions directory: $COMPDIR" >&2
  COMPDIR="${TMPDIR:-/tmp}/zsh-completions-$$"
  mkdir -p "$COMPDIR" || {
    echo "❌ Error: Failed to create fallback completions directory" >&2
    return 1
  }
fi

# Helper: generate completion file if command exists and file is missing
# Usage: _gen_comp_if_missing <cmd> <outfile> <generator...>
_gen_comp_if_missing() {
  local _cmd="$1" _outfile="$2"; shift 2
  if command -v "$_cmd" &>/dev/null; then
    if [[ ! -s "$_outfile" || -n "$ZSH_COMP_REFRESH" ]]; then
      # shellcheck disable=SC2068
      "$@" >"$_outfile" 2>/dev/null || true
    fi
  fi
}

# === Static, native Zsh completion generators (preferred; fastest) ===========
# glab
_gen_comp_if_missing glab        "$COMPDIR/_glab"        glab completion -s zsh
# warp-cli (Cloudflare WARP)
_gen_comp_if_missing warp-cli    "$COMPDIR/_warp-cli"    warp-cli generate-completions zsh
# docker
_gen_comp_if_missing docker      "$COMPDIR/_docker"      docker completion zsh
# argocd
_gen_comp_if_missing argocd      "$COMPDIR/_argocd"      argocd completion zsh
# helm
_gen_comp_if_missing helm        "$COMPDIR/_helm"        helm completion zsh
# kubectl
_gen_comp_if_missing kubectl     "$COMPDIR/_kubectl"     kubectl completion zsh
# mise
_gen_comp_if_missing mise        "$COMPDIR/_mise"        mise completion zsh
# gh (GitHub CLI)
_gen_comp_if_missing gh          "$COMPDIR/_gh"          gh completion -s zsh
# kind
_gen_comp_if_missing kind        "$COMPDIR/_kind"        kind completion zsh

# k9s (Kubernetes CLI)
_gen_comp_if_missing k9s         "$COMPDIR/_k9s"        k9s completion zsh

# pdm (Python Dependency Manager)
_gen_comp_if_missing pdm         "$COMPDIR/_pdm"        pdm completion zsh

# deno
_gen_comp_if_missing deno        "$COMPDIR/_deno"       deno completions zsh

# atuin (shell history manager)
_gen_comp_if_missing atuin       "$COMPDIR/_atuin"      atuin gen-completions -s zsh

# cargo (Rust package manager) - if rustup is available
if command -v rustup &>/dev/null; then
  _gen_comp_if_missing cargo     "$COMPDIR/_cargo"      rustup completions zsh cargo
elif command -v cargo &>/dev/null; then
  # Fallback: cargo might have its own completion
  _gen_comp_if_missing cargo     "$COMPDIR/_cargo"      cargo completions zsh
fi

# Byte-compile individual completion functions for speed (best-effort)
# Only compile if directory exists and contains files
if [[ -d "$COMPDIR" ]]; then
  for f in "$COMPDIR"/_*; do
    [[ -f "$f" ]] && zcompile "$f" 2>/dev/null || true
  done
fi

# Put our completions first in fpath, then init (with caching)
fpath=("$COMPDIR" $fpath)

autoload -Uz compinit
_compdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -s "$_compdump" || "$_compdump" -nt "${_compdump}.zwc" ]]; then
  compinit -i -d "$_compdump"
  zcompile -R "${_compdump}.zwc" "$_compdump" 2>/dev/null
else
  compinit -i -C -d "$_compdump"
fi

# === Bash-style completion fallbacks (only if needed) ========================
# These tools don't ship native zsh comps (or are bash-flavored).
# We enable bashcompinit ONLY if at least one is present.

_need_bashcomp=false
typeset -g -a _bash_fallbacks  # Initialize array once at the start

# Terraform fallback: if no native _terraform was produced above
if command -v terraform &>/dev/null && [[ ! -s "$COMPDIR/_terraform" ]]; then
  # Try native terraform completion generation first
  if terraform -install-autocomplete zsh &>/dev/null && [[ -f "$HOME/.terraform.d/autocomplete/zsh_autocomplete" ]]; then
    source "$HOME/.terraform.d/autocomplete/zsh_autocomplete" 2>/dev/null || {
      # Fallback to bash-style if native completion failed
      _need_bashcomp=true
      _bash_fallbacks+=("complete -o nospace -C $(command -v terraform) terraform")
    }
  else
    # Use bash-style completion as fallback
    _need_bashcomp=true
    _bash_fallbacks+=("complete -o nospace -C $(command -v terraform) terraform")
  fi
fi

# AWS CLI
if command -v aws &>/dev/null && command -v aws_completer &>/dev/null; then
  _need_bashcomp=true
  _bash_fallbacks+=("complete -C $(command -v aws_completer) aws")
fi

# NPM
if command -v npm &>/dev/null; then
  _need_bashcomp=true
  # Using npm completion (bash-style)
  _bash_fallbacks+=("eval 'source <(npm completion)'")
fi

# Node.js (nvm completion)
if command -v nvm &>/dev/null; then
  _need_bashcomp=true
  _bash_fallbacks+=("source <(nvm completion)")
fi

# Yarn
if command -v yarn &>/dev/null; then
  _need_bashcomp=true
  _bash_fallbacks+=("source <(yarn completion)")
fi

if [[ "$_need_bashcomp" == true ]]; then
  autoload -U +X bashcompinit && bashcompinit
  for _cmd in "${_bash_fallbacks[@]}"; do
    eval "$_cmd" 2>/dev/null || true
  done
fi

# === Extra (non-completion) environment bits you listed ======================
# Cargo/Rust env (kept as-is)
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

# --- End fast completions bootstrap -----------------------------------------
# Note: Some tools handle their own completions via init commands in zshrc:
# - atuin: handled by 'atuin init zsh' in zshrc
# - zoxide: handled by 'zoxide init zsh' in zshrc
# - direnv: completion file generated above, but hook is in OMZP::direnv
#
# Tools without standard completion support (or handled differently):
# - yazi: file manager, doesn't need shell completions
# - bat: simple tool, doesn't need completions
# - neovim: editor, doesn't need completions
# - go, ruby, node: language runtimes, completions handled by tools/plugins
# - xh, prettier: may have completions but not critical
#
# Tips:
# - Set ZSH_COMP_REFRESH=1 when sourcing this file to force regeneration.
# - Set ZSH_SKIP_TERRAFORM_INSTALL=1 to skip 'terraform -install-autocomplete'.
