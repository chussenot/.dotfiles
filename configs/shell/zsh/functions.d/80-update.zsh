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
  # Update pinned versions in conf.d files
  local _pins_script="${DOTFILES_DIR:-$HOME/.dotfiles}/scripts/utils/mise-update-pins.sh"
  if [[ -x "$_pins_script" ]]; then
    echo "📌 Checking for outdated pinned versions..."
    "$_pins_script"
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

# --- public orchestrator ----------------------------------------------------

function update {
  echo "🔄 Updating your development environment..."
  local errors=0
  local start_time=$(date +%s)
  local step
  for step in _update_apt _update_tpm _update_antidote _update_nvim _update_mise _update_krew _update_compinit; do
    "$step" || ((errors++))
  done
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  if (( errors == 0 )); then
    echo "✅ Update complete! Your system is now up to date. (took ${duration}s)"
  else
    echo "⚠️  Update completed with $errors error(s) in ${duration}s. Check the output above for details."
  fi
}
