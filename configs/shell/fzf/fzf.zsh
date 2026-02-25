# Setup fzf
# ---------
if [[ ! "$PATH" == */home/chussenot/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/chussenot/.fzf/bin"
fi

source <(fzf --zsh)

# Use fd for fzf file search (CTRL+T) if available
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
