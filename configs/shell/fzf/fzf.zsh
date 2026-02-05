# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Use explicit path to ensure we use ~/.fzf version
if [[ -x "$HOME/.fzf/bin/fzf" ]]; then
  source <("$HOME/.fzf/bin/fzf" --zsh)
elif command -v fzf &>/dev/null; then
  # Fallback to system fzf with older syntax
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2>/dev/null
  source "$HOME/.fzf/shell/key-bindings.zsh" 2>/dev/null
fi
