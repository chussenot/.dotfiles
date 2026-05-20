# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# File and directory helpers.

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
  export _tmpdir_current="$tmp_dir"
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
  if [[ -n "${_tmpdir_current:-}" ]] && [[ -d "$_tmpdir_current" ]]; then
    cd "$_tmpdir_current"
  else
    tmpdir
  fi
}
