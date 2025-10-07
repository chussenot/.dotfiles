# --- Fast Zsh completions bootstrap -----------------------------------------
# Goal: generate once, then load fast on every shell start

# Directory to store generated completion files
COMPDIR="${ZDOTDIR:-$HOME}/.zsh/completions"
mkdir -p "$COMPDIR"

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
# pip
_gen_comp_if_missing pip         "$COMPDIR/_pip"         pip completion --zsh
# mise
_gen_comp_if_missing mise        "$COMPDIR/_mise"        mise completion zsh
# gh (GitHub CLI)
_gen_comp_if_missing gh          "$COMPDIR/_gh"          gh completion -s zsh
# kind
_gen_comp_if_missing kind        "$COMPDIR/_kind"        kind completion zsh

# Terraform: try native installer once (creates proper _terraform file);
# fall back to bashcompinit (below) if unavailable.
if command -v terraform &>/dev/null; then
  if [[ ! -s "$COMPDIR/_terraform" && -z "${ZSH_SKIP_TERRAFORM_INSTALL:-}" ]]; then
    terraform -install-autocomplete &>/dev/null || true
    # Some installs put it under ~/.zfunc; copy if found
    if [[ -s "$HOME/.zfunc/_terraform" && ! -s "$COMPDIR/_terraform" ]]; then
      cp "$HOME/.zfunc/_terraform" "$COMPDIR/_terraform" 2>/dev/null || true
    fi
  fi
fi

# Byte-compile individual completion functions for speed (best-effort)
for f in "$COMPDIR"/_*; do
  [[ -f "$f" ]] && zcompile "$f" 2>/dev/null || true
done

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

# Terraform fallback: if no native _terraform was produced above
if command -v terraform &>/dev/null && [[ ! -s "$COMPDIR/_terraform" ]]; then
  _need_bashcomp=true
  typeset -g -a _bash_fallbacks
  _bash_fallbacks+=("complete -o nospace -C $(command -v terraform) terraform")
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
# Tips:
# - Set ZSH_COMP_REFRESH=1 when sourcing this file to force regeneration.
# - Set ZSH_SKIP_TERRAFORM_INSTALL=1 to skip 'terraform -install-autocomplete'.
