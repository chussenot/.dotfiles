# Zsh Functions
# This file contains all shell functions

# Create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create a backup of a file
bak() {
    cp "$1" "$1.bak"
}

# Git functions
gac() {
    git add . && git commit -m "$1"
}

gacp() {
    git add . && git commit -m "$1" && git push
}

# Docker functions
dclean() {
    docker system prune -f
    docker image prune -f
    docker container prune -f
    docker volume prune -f
}

# System functions
meminfo() {
    free -h | grep -E "Mem|Swap"
}

cpuinfo() {
    lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
}
# Development functions
pyvenv() {
    python3 -m venv "$1" && source "$1/bin/activate"
}

# Tmux functions
tdev() {
    if tmux has-session -t dev 2>/dev/null; then
        tmux attach-session -t dev
    else
        tmux new-session -s dev -d
        tmux split-window -h
        tmux split-window -v
        tmux select-pane -t 0
        tmux attach-session -t dev
    fi
}

function reload {
  echo "🔄 Reloading ZSH configuration..."
  source ~/.zshrc
  echo "✅ ZSH configuration reloaded successfully!"
}

# Quick edit and reload zshrc
function zshconfig {
  $EDITOR ~/.zshrc && reload
}

# List all available aliases
function aliases {
  echo "🔍 Your current aliases:"
  alias | sort | grep -v "^_" | bat --style=plain --language=bash
}

function update {
  echo "🔄 Updating your development environment..."
  
  # Update system packages if on Ubuntu/Debian
  if command -v apt &>/dev/null; then
    echo "📦 Updating system packages..."
    sudo apt update && sudo apt upgrade -y
  fi
  
  # Update zinit and plugins
  echo "📦 Updating zinit plugins..."
  zinit self-update
  zinit update --parallel
    
  # Update Neovim plugins
  if command -v nvim &>/dev/null; then
    echo "🧩 Updating Neovim plugins..."
    nvim --headless +PlugUpdate +qall
  fi
  
  # Update mise tools
  if command -v mise &>/dev/null; then
    echo "🛠️  Updating mise tools..."
    mise self-update
    mise upgrade
  fi
  
  # Update Oh-My-Zsh
  echo "🐚 Updating Oh-My-Zsh..."
  omz update

  # Refresh completions
  echo "🔄 Refreshing completions..."
  autoload -Uz compinit
  compinit -C
      
  echo "✅ Update complete! Your system is now up to date."
}

############################
# Yazi integration
############################

if command -v yazi >/dev/null 2>&1; then
  # yy : ouvre Yazi puis cd dans le dernier dossier visité
  # Unalias yy if it exists (from plugins or other sources)
  unalias yy 2>/dev/null || true
  yy() {
    local tmp="$(mktemp)"
    yazi "$@" --cwd-file="$tmp"
    local cwd
    cwd="$(cat "$tmp" 2>/dev/null)"
    rm -f "$tmp"
    [ -n "$cwd" ] && cd "$cwd"
  }

  # y : lance juste Yazi dans le dossier courant
  alias y="yazi"
fi

# Alt-o pour lancer yy
bindkey -s '^[o' 'yy\n'
