# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# Zsh-specific utilities: completions, reload helpers, alias inspector.

# Completion for `mr` alias — avoids usage CLI overhead
_mr_completion() {
  local tasks
  tasks=(${(f)"$(mise tasks ls --no-header 2>/dev/null | awk '{print $1}')"})
  _describe 'mise tasks' tasks
}
compdef _mr_completion mr

# Force regeneration of zcompdump and re-run compinit
zreset() {
  rm -f ~/.zcompdump*
  autoload -Uz compinit
  compinit
  echo "Completions reset"
}

# Re-source ~/.zshrc
function reload {
  echo "🔄 Reloading ZSH configuration..."
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  if [[ -f "$zshrc_file" ]]; then
    source "$zshrc_file"
    echo "✅ ZSH configuration reloaded successfully!"
  else
    echo "❌ Error: $zshrc_file not found" >&2
    return 1
  fi
}

# Open ~/.zshrc in $EDITOR, then reload
function zshconfig {
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  local editor="${EDITOR:-nvim}"

  if ! command -v "$editor" &>/dev/null; then
    echo "❌ Error: $editor not found" >&2
    return 1
  fi

  "$editor" "$zshrc_file" && reload
}

# Pretty-print all current aliases (bat-highlighted when available)
function aliases {
  echo "🔍 Your current aliases:"
  if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
    local bat_cmd=$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)
    alias | sort | grep -v "^_" | "$bat_cmd" --style=plain --language=bash
  else
    alias | sort | grep -v "^_"
  fi
}
