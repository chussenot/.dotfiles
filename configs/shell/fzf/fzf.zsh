# Setup fzf
# ---------
source <(fzf --zsh)

# Use fd for fzf file search (CTRL+T) if available
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# UI defaults: 60% height (not full-screen), reverse layout, border, inline info.
# Opts only affect fzf's own rendering — no change to what gets searched/returned.
export FZF_DEFAULT_OPTS='--height 60% --layout reverse --border --info inline'

# CTRL-T previews the file with bat (syntax highlight + line numbers); falls back
# to plain cat for anything bat can't render. Guarded so it no-ops without bat.
if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {} 2>/dev/null || cat {}' --preview-window right:60%:wrap"
fi

# ALT-C previews the directory as a 2-level eza tree. Guarded on eza.
if command -v eza &>/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza -T --color=always --level=2 {} 2>/dev/null | head -200'"
fi
