# Setup fzf
# ---------
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Use explicit path to ensure we use ~/.fzf version
if [[ -x "$HOME/.fzf/bin/fzf" ]]; then
  eval "$("$HOME/.fzf/bin/fzf" --bash)"
elif command -v fzf &>/dev/null; then
  # Fallback to system fzf with older syntax
  [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2>/dev/null
  source "$HOME/.fzf/shell/key-bindings.bash" 2>/dev/null
fi
