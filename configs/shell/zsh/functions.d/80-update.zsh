# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# `update` orchestrator and its per-tool helpers.
#
# Each `_update_*` helper returns 0 on success / no-op, non-zero on failure.
# `update` aggregates failures and prints a final summary.

# Install / refresh kubectl-krew plugins from ~/.krew-plugins
function krew-sync {
  local plugins_file="${HOME}/.krew-plugins"
  if ! command -v krew &>/dev/null; then
    echo "❌ krew is not installed"
    return 1
  fi
  if [[ ! -f "$plugins_file" ]]; then
    echo "❌ $plugins_file not found"
    return 1
  fi
  echo "🔌 Syncing krew plugins from $plugins_file..."
  krew update || return 1
  while IFS= read -r plugin || [[ -n "$plugin" ]]; do
    [[ -z "$plugin" || "$plugin" == \#* ]] && continue
    echo "  → $plugin"
    krew install "$plugin" 2>/dev/null || true
  done < "$plugins_file"
  krew upgrade
}

# --- per-tool helpers used by `update` --------------------------------------

# apt update + upgrade. inotify sysctl is handled by install-packages.sh,
# not here — `update` must not modify /etc/sysctl.d.
_update_apt() {
  command -v apt &>/dev/null || return 0
  echo "📦 Updating system packages..."
  sudo apt update && sudo apt upgrade -y
}

_update_tpm() {
  [[ -d "$HOME/.tmux/plugins/tpm" ]] || return 0
  echo "🔄 Updating TPM..."
  (cd "$HOME/.tmux/plugins/tpm" && git pull --rebase 2>/dev/null)
}

_update_antidote() {
  command -v antidote &>/dev/null || return 0
  echo "📦 Updating antidote plugins..."
  (cd "${HOME}/.antidote" && git pull --rebase 2>/dev/null) || true
  antidote update 2>/dev/null
}

_update_nvim() {
  command -v nvim &>/dev/null || return 0
  echo "🧩 Updating Neovim plugins..."
  nvim --headless +PlugUpdate +qall 2>/dev/null
}

_update_mise() {
  command -v mise &>/dev/null || return 0
  echo "🛠️  Updating mise tools..."
  mise self-update 2>/dev/null || true
  mise upgrade 2>/dev/null || return 1

  local _dotfiles="${DOTFILES_DIR:-$HOME/.dotfiles}"

  # Update pinned versions in conf.d files
  local _pins_script="${_dotfiles}/scripts/utils/mise-update-pins.sh"
  if [[ -x "$_pins_script" ]]; then
    echo "📌 Checking for outdated pinned versions..."
    "$_pins_script"
  fi

  # Install the (possibly re-pinned) tools and refresh the cross-platform
  # lockfile. Run inside the dotfiles repo so repo-scoped tools resolve and
  # mise.lock is written there; fall back to a plain install otherwise.
  if [[ -d "$_dotfiles" ]]; then
    echo "⬇️  Installing pinned mise tools..."
    (cd "$_dotfiles" && mise install) 2>/dev/null || return 1
    # `mise lock` is a recent subcommand — skip gracefully on older mise.
    if mise lock --help &>/dev/null; then
      echo "🔒 Regenerating ${_dotfiles}/mise.lock..."
      (cd "$_dotfiles" && mise lock) || return 1
    fi
  else
    echo "⬇️  Installing pinned mise tools..."
    mise install 2>/dev/null || return 1
  fi
}

_update_krew() {
  command -v krew &>/dev/null || return 0
  [[ -f "$HOME/.krew-plugins" ]] || return 0
  krew-sync
}

_update_compinit() {
  echo "🔄 Refreshing completions..."
  autoload -Uz compinit
  compinit -C 2>/dev/null || true

  # Force completion regeneration if requested
  if [[ -n "${ZSH_COMP_REFRESH:-}" ]]; then
    echo "🔄 Forcing completion regeneration..."
    ZSH_COMP_REFRESH=1 source "${ZDOTDIR:-$HOME}/.zsh/_completions.zsh" 2>/dev/null || true
  fi
}

# Refresh sudo once before backgrounding apt to avoid concurrent password
# prompts racing with other update jobs. If it fails, apt can still run
# later in the foreground and preserve the old behavior.
_prepare_update_apt_auth() {
  command -v apt &>/dev/null || return 1
  command -v sudo &>/dev/null || return 1

  echo "🔐 Refreshing sudo credentials for apt..."
  sudo -v
}

# --- public orchestrator ----------------------------------------------------

function update {
  echo "🔄 Updating your development environment..."
  local errors=0
  local start_time=$(date +%s)
  local step
  local apt_mode=skip
  local -a async_steps async_names async_pids
  local _index

  async_steps=(_update_tpm _update_antidote _update_nvim _update_mise _update_krew)

  if command -v apt &>/dev/null; then
    if _prepare_update_apt_auth; then
      apt_mode=async
      async_steps=(_update_apt "${async_steps[@]}")
    else
      apt_mode=serial
      echo "⚠️  Sudo preflight failed; apt updates will run serially." >&2
    fi
  fi

  for step in "${async_steps[@]}"; do
    "$step" &
    async_names+=("$step")
    async_pids+=("$!")
  done

  for (( _index = 1; _index <= ${#async_pids[@]}; _index++ )); do
    if ! wait "${async_pids[_index]}"; then
      echo "⚠️  ${async_names[_index]} failed."
      ((errors++))
    fi
  done

  if [[ "$apt_mode" == serial ]]; then
    _update_apt || ((errors++))
  fi

  if ! _update_compinit; then
    ((errors++))
  fi
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  if (( errors == 0 )); then
    echo "✅ Update complete! Your system is now up to date. (took ${duration}s)"
  else
    echo "⚠️  Update completed with $errors error(s) in ${duration}s. Check the output above for details."
  fi
}
