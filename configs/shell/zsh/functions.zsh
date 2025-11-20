# Zsh Functions
# This file contains all shell functions

# Create a directory and cd into it
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi
    mkdir -p "$1" && cd "$1" || {
        echo "Error: Failed to create or change to directory: $1" >&2
        return 1
    }
}

# Extract various archive formats
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <archive>" >&2
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file" >&2
        return 1
    fi
    
    local success=0
    case "$1" in
        *.tar.bz2|*.tbz2)   tar xjf "$1" && success=1     ;;
        *.tar.gz|*.tgz)     tar xzf "$1" && success=1     ;;
        *.tar.xz)           tar xJf "$1" && success=1     ;;
        *.tar)              tar xf "$1" && success=1      ;;
        *.bz2)              bunzip2 "$1" && success=1     ;;
        *.rar)              unrar e "$1" && success=1     ;;
        *.gz)               gunzip "$1" && success=1      ;;
        *.zip)              unzip "$1" && success=1       ;;
        *.Z)                uncompress "$1" && success=1  ;;
        *.7z)               7z x "$1" && success=1       ;;
        *.xz)               xz -d "$1" && success=1       ;;
        *)                  echo "Error: '$1' cannot be extracted via extract()" >&2 ;;
    esac
    
    [[ $success -eq 1 ]] && echo "✅ Extracted: $1" || return 1
}

# Create a backup of a file
bak() {
    if [[ -z "$1" ]]; then
        echo "Usage: bak <file>" >&2
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file" >&2
        return 1
    fi
    cp "$1" "$1.bak" && echo "✅ Backup created: $1.bak" || {
        echo "Error: Failed to create backup" >&2
        return 1
    }
}

# Git functions
gac() {
    if [[ -z "$1" ]]; then
        echo "Usage: gac <commit-message>" >&2
        return 1
    fi
    git add . && git commit -m "$1"
}

gacp() {
    if [[ -z "$1" ]]; then
        echo "Usage: gacp <commit-message>" >&2
        return 1
    fi
    git add . && git commit -m "$1" && git push
}

# Docker functions
dclean() {
    if ! command -v docker &>/dev/null; then
        echo "Error: docker is not installed" >&2
        return 1
    fi
    docker system prune -f
    docker image prune -f
    docker container prune -f
    docker volume prune -f
    echo "✅ Docker cleanup complete"
}

# System functions
meminfo() {
    if command -v free &>/dev/null; then
        free -h | grep -E "Mem|Swap"
    else
        echo "Error: free command not found" >&2
        return 1
    fi
}

cpuinfo() {
    if command -v lscpu &>/dev/null; then
        lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
    else
        echo "Error: lscpu command not found" >&2
        return 1
    fi
}
# Development functions
pyvenv() {
    if [[ -z "$1" ]]; then
        echo "Usage: pyvenv <venv-name>" >&2
        return 1
    fi
    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 is not installed" >&2
        return 1
    fi
    python3 -m venv "$1" && source "$1/bin/activate" || {
        echo "Error: Failed to create virtual environment" >&2
        return 1
    }
}

# Tmux functions
tdev() {
    if ! command -v tmux &>/dev/null; then
        echo "Error: tmux is not installed" >&2
        return 1
    fi
    
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
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  if [[ -f "$zshrc_file" ]]; then
    source "$zshrc_file"
    echo "✅ ZSH configuration reloaded successfully!"
  else
    echo "❌ Error: $zshrc_file not found" >&2
    return 1
  fi
}

# Quick edit and reload zshrc
function zshconfig {
  local zshrc_file="${ZDOTDIR:-$HOME}/.zshrc"
  local editor="${EDITOR:-nvim}"
  
  if ! command -v "$editor" &>/dev/null; then
    echo "❌ Error: $editor not found" >&2
    return 1
  fi
  
  "$editor" "$zshrc_file" && reload
}

# List all available aliases
function aliases {
  echo "🔍 Your current aliases:"
  if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
    local bat_cmd=$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)
    alias | sort | grep -v "^_" | "$bat_cmd" --style=plain --language=bash
  else
    alias | sort | grep -v "^_"
  fi
}

# Find files by name (case-insensitive)
function ff() {
  if [[ -z "$1" ]]; then
    echo "Usage: ff <pattern>" >&2
    return 1
  fi
  
  if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
    local fd_cmd=$(command -v fd 2>/dev/null || command -v fdfind 2>/dev/null)
    "$fd_cmd" -i "$1"
  elif command -v find &>/dev/null; then
    find . -iname "*$1*" 2>/dev/null
  else
    echo "Error: fd or find not found" >&2
    return 1
  fi
}

# Find text in files
function ftext() {
  if [[ -z "$1" ]]; then
    echo "Usage: ftext <pattern>" >&2
    return 1
  fi
  
  if command -v rg &>/dev/null; then
    rg "$1"
  elif command -v grep &>/dev/null; then
    grep -r "$1" .
  else
    echo "Error: ripgrep or grep not found" >&2
    return 1
  fi
}

# Create a temporary directory and cd into it
function tmpdir() {
  local tmp_dir
  tmp_dir=$(mktemp -d) || {
    echo "Error: Failed to create temporary directory" >&2
    return 1
  }
  cd "$tmp_dir" && echo "📁 Created and entered: $tmp_dir"
}

function update {
  echo "🔄 Updating your development environment..."
  local errors=0
  
  # Update system packages if on Ubuntu/Debian
  if command -v apt &>/dev/null; then
    echo "📦 Updating system packages..."
    sudo apt update && sudo apt upgrade -y || ((errors++))
  fi
  
  # Update zinit and plugins
  if command -v zinit &>/dev/null; then
    echo "📦 Updating zinit plugins..."
    zinit self-update 2>/dev/null || true
    zinit update --parallel 2>/dev/null || ((errors++))
  fi
    
  # Update Neovim plugins
  if command -v nvim &>/dev/null; then
    echo "🧩 Updating Neovim plugins..."
    nvim --headless +PlugUpdate +qall 2>/dev/null || ((errors++))
  fi
  
  # Update mise tools
  if command -v mise &>/dev/null; then
    echo "🛠️  Updating mise tools..."
    mise self-update 2>/dev/null || true
    mise upgrade 2>/dev/null || ((errors++))
  fi
  
  # Update Oh-My-Zsh
  if command -v omz &>/dev/null; then
    echo "🐚 Updating Oh-My-Zsh..."
    omz update 2>/dev/null || ((errors++))
  fi

  # Refresh completions
  echo "🔄 Refreshing completions..."
  autoload -Uz compinit
  compinit -C 2>/dev/null || true
      
  if [[ $errors -eq 0 ]]; then
    echo "✅ Update complete! Your system is now up to date."
  else
    echo "⚠️  Update completed with $errors error(s). Check the output above for details."
  fi
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
