# Setup fzf
# ---------
if [[ ! "$PATH" == */home/chussenot/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/chussenot/.fzf/bin"
fi

source <(fzf --zsh)
