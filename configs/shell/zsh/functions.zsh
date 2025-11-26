# shellcheck shell=bash disable=SC1090,SC2155,SC2164
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
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    git add . && git commit -m "$1"
}

gacp() {
    if [[ -z "$1" ]]; then
        echo "Usage: gacp <commit-message>" >&2
        return 1
    fi
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    git add . && git commit -m "$1" && git push
}

# Quick git status
function gst() {
    if git rev-parse --git-dir &>/dev/null; then
        git status
    else
        echo "Error: Not in a git repository" >&2
        return 1
    fi
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
    echo "Usage: ftext <pattern> [directory]" >&2
    return 1
  fi

  local search_dir="${2:-.}"

  if command -v rg &>/dev/null; then
    rg "$1" "$search_dir"
  elif command -v grep &>/dev/null; then
    grep -r "$1" "$search_dir"
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
  # Store path in variable for easy access
  export TMPDIR_CURRENT="$tmp_dir"
}

# Quick access to common directories
function cdd() {
  # cd to dotfiles directory
  cd "${DOTFILES_DIR:-$HOME/.dotfiles}" 2>/dev/null || cd "$HOME/.dotfiles" 2>/dev/null || {
    echo "Error: dotfiles directory not found" >&2
    return 1
  }
}

# Quick access to temporary directory
function cdtmp() {
  if [[ -n "${TMPDIR_CURRENT:-}" ]] && [[ -d "$TMPDIR_CURRENT" ]]; then
    cd "$TMPDIR_CURRENT"
  else
    tmpdir
  fi
}

function update {
  echo "🔄 Updating your development environment..."
  local errors=0
  local start_time=$(date +%s)

  # Update system packages if on Ubuntu/Debian
  if command -v apt &>/dev/null; then
    echo "📦 Updating system packages..."
    sudo apt update && sudo apt upgrade -y || ((errors++))
  fi

  # Update fzf repository
  if [[ -d "$HOME/.fzf" ]]; then
    echo "🔄 Updating fzf repository..."
    cd "$HOME/.fzf" && git pull --rebase 2>/dev/null && cd - || ((errors++))
    if [[ $errors -eq 0 ]]; then
      echo "✅ fzf repository updated successfully!"
    else
      echo "⚠️  Error: Failed to update fzf repository"
    fi
  fi

  # Update TPM (tmux plugin manager)
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "🔄 Updating TPM..."
    (cd "$HOME/.tmux/plugins/tpm" && git pull --rebase 2>/dev/null) || ((errors++))
  fi

  # Update antidote and plugins
  if command -v antidote &>/dev/null; then
    echo "📦 Updating antidote plugins..."
    (cd "${HOME}/.antidote" && git pull --rebase 2>/dev/null) || true
    antidote update 2>/dev/null || ((errors++))
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


  # Refresh completions
  echo "🔄 Refreshing completions..."
  autoload -Uz compinit
  compinit -C 2>/dev/null || true

  # Force completion regeneration if requested
  if [[ -n "${ZSH_COMP_REFRESH:-}" ]]; then
    echo "🔄 Forcing completion regeneration..."
    ZSH_COMP_REFRESH=1 source "${ZDOTDIR:-$HOME}/.zsh/_completions.zsh" 2>/dev/null || true
  fi

  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  if [[ $errors -eq 0 ]]; then
    echo "✅ Update complete! Your system is now up to date. (took ${duration}s)"
  else
    echo "⚠️  Update completed with $errors error(s) in ${duration}s. Check the output above for details."
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

############################
# sudo
############################

__sudo-replace-buffer() {
  local old=$1 new=$2 space=${2:+ }

  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

sudo-command-line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi

  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
        sudo\ *) __sudo-replace-buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      __sudo-replace-buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) __sudo-replace-buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle && zle redisplay # only run redisplay if zle is enabled
  }
}

zle -N sudo-command-line

# Defined shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line
