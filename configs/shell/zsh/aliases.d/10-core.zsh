# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Core aliases — navigation, listing, git, dev, system, utility, safety.

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List aliases
alias ll='ls -alF'
alias lt='ls -lt'
alias ltr='ls -ltr'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
# Note: gst is defined as a function in functions.d/20-git.zsh with error handling
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gd='git diff'
alias gdc='git diff --cached'
alias glog='git log --oneline --graph --decorate'
alias gfa='git fetch --all --prune'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'

# Development aliases
alias m='mise'
alias mi='mise install'
alias mr='mise run'
alias pr='pdm run'
alias py='python3'
# Note: `alias pip='pip3'` removed — it breaks `pip` inside uv venvs (which
# expose only bin/pip, not bin/pip3). Use `python3 -m pip` for the system
# interpreter, or just `pip` once a venv is active.
alias v='nvim'
alias help='glow -p ~/.dotfiles/help.md'

# prek is installed via mise (see configs/tools/mise/conf.d/05-dev-tools.toml)
if command -v prek &>/dev/null; then
  alias pre-commit=prek
fi

# System aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'
# Use htop if available, otherwise fall back to top
if command -v htop &>/dev/null; then
  alias top='htop'
fi

# Utility aliases
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
# Network aliases (conditional based on available tools)
if command -v netstat &>/dev/null; then
  alias ports='netstat -tulanp'
elif command -v ss &>/dev/null; then
  alias ports='ss -tulanp'
fi

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
