# Chussenot Zsh Theme
# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Refactored for better maintainability and performance

# =============================================================================
# Configuration Variables
# =============================================================================

# Theme configuration (can be overridden by setting these variables before sourcing)
: ${CT_SHOW_EXIT_CODE:=true}
: ${CT_SHOW_TIMESTAMP:=false}
: ${CT_SHOW_VENV:=true}
: ${CT_SHOW_VCS:=true}
: ${CT_VCS_SYMBOLS:=true}
: ${CT_SHOW_PYTHON:=true}
: ${CT_SHOW_NODE:=true}
: ${CT_SHOW_GO:=true}

# VCS (Version Control System) styling
CT_VCS_PREFIX=" %{$reset_color%}on%{$fg[blue]%} "
CT_VCS_SEPARATOR=":%{$fg[cyan]%}"
CT_VCS_SUFFIX="%{$reset_color%}"

# VCS status symbols (can be customized)
if [[ "$CT_VCS_SYMBOLS" == "true" ]]; then
    CT_VCS_DIRTY=" %{$fg[red]%}✗"
    CT_VCS_CLEAN=" %{$fg[green]%}✓"
else
    CT_VCS_DIRTY=" %{$fg[red]%}x"
    CT_VCS_CLEAN=" %{$fg[green]%}o"
fi

# Virtual environment styling
CT_VENV_PREFIX=" %{$fg[green]%}"
CT_VENV_SUFFIX="%{$reset_color%}"

# Exit code styling
CT_EXIT_CODE_PREFIX="C:%{$fg[red]%}"
CT_EXIT_CODE_SUFFIX="%{$reset_color%}"

# Python styling
CT_PYTHON_PREFIX=" %{$fg[yellow]%}py:"
CT_PYTHON_SUFFIX="%{$reset_color%}"

# Node.js styling
CT_NODE_PREFIX=" %{$fg[green]%}node:"
CT_NODE_SUFFIX="%{$reset_color%}"

# Go styling
CT_GO_PREFIX=" %{$fg[cyan]%}go:"
CT_GO_SUFFIX="%{$reset_color%}"

# =============================================================================
# VCS Prompt Functions
# =============================================================================

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="${CT_VCS_PREFIX}git${CT_VCS_SEPARATOR}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$CT_VCS_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$CT_VCS_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$CT_VCS_CLEAN"

# =============================================================================
# Virtual Environment Function
# =============================================================================

virtualenv_prompt() {
    # Check if virtual environment should be shown
    [[ "$CT_SHOW_VENV" == "true" ]] || return
    [[ -n "${VIRTUAL_ENV:-}" ]] || return
    
    echo "${CT_VENV_PREFIX}${VIRTUAL_ENV:t}${CT_VENV_SUFFIX}"
}

# =============================================================================
# Exit Code Function
# =============================================================================

exit_code() {
    # Check if exit code should be shown
    [[ "$CT_SHOW_EXIT_CODE" == "true" ]] || return
    
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo " ${CT_EXIT_CODE_PREFIX}${exit_code}${CT_EXIT_CODE_SUFFIX}"
    fi
}

# =============================================================================
# Python Version Function
# =============================================================================

python_version() {
    # Check if Python version should be shown
    [[ "$CT_SHOW_PYTHON" == "true" ]] || return
    
    # Check if Python is available
    command -v python3 >/dev/null 2>&1 || return
    
    local py_version
    py_version=$(python3 --version 2>/dev/null | sed 's/Python //') || return
    
    # Show only major.minor version (e.g., 3.11 instead of 3.11.5)
    py_version="${py_version%.*}"
    
    echo "${CT_PYTHON_PREFIX}${py_version}${CT_PYTHON_SUFFIX}"
}

# =============================================================================
# Node.js Version Function
# =============================================================================

node_version() {
    # Check if Node.js version should be shown
    [[ "$CT_SHOW_NODE" == "true" ]] || return
    
    # Check if Node.js is available
    command -v node >/dev/null 2>&1 || return
    
    local node_ver
    node_ver=$(node --version 2>/dev/null | sed 's/v//') || return
    
    # Show only major.minor version (e.g., 18.17 instead of 18.17.0)
    node_ver="${node_ver%.*}"
    
    echo "${CT_NODE_PREFIX}${node_ver}${CT_NODE_SUFFIX}"
}

# =============================================================================
# Go Version Function
# =============================================================================

go_version() {
    # Check if Go version should be shown
    [[ "$CT_SHOW_GO" == "true" ]] || return
    
    # Check if Go is available
    command -v go >/dev/null 2>&1 || return
    
    local go_ver
    go_ver=$(go version 2>/dev/null | sed 's/go version go//' | awk '{print $1}') || return
    
    # Show only major.minor version (e.g., 1.21 instead of 1.21.5)
    go_ver="${go_ver%.*}"
    
    echo "${CT_GO_PREFIX}${go_ver}${CT_GO_SUFFIX}"
}

# =============================================================================
# Prompt Variables (for performance)
# =============================================================================

# Pre-compute VCS info for better performance (only if enabled)
if [[ "$CT_SHOW_VCS" == "true" ]]; then
    local git_info='$(git_prompt_info)'
else
    local git_info=''
fi

# Virtual environment info (only if enabled)
if [[ "$CT_SHOW_VENV" == "true" ]]; then
    local venv_info='$(virtualenv_prompt)'
else
    local venv_info=''
fi

# Python version info (only if enabled)
if [[ "$CT_SHOW_PYTHON" == "true" ]]; then
    local python_info='$(python_version)'
else
    local python_info=''
fi

# Node.js version info (only if enabled)
if [[ "$CT_SHOW_NODE" == "true" ]]; then
    local node_info='$(node_version)'
else
    local node_info=''
fi

# Go version info (only if enabled)
if [[ "$CT_SHOW_GO" == "true" ]]; then
    local go_info='$(go_version)'
else
    local go_info=''
fi

# Exit code info (only if enabled)
if [[ "$CT_SHOW_EXIT_CODE" == "true" ]]; then
    local exit_code='$(exit_code)'
else
    local exit_code=''
fi

# =============================================================================
# Main Prompt Configuration
# =============================================================================

# Prompt format:
# PRIVILEGES USER @ MACHINE in DIRECTORY py:VERSION node:VERSION go:VERSION on git:BRANCH STATE C:EXIT_CODE
# $ COMMAND
#
# Example:
# # chussenot @ hostname in ~/.dotfiles py:3.11 node:18.17 go:1.21 on git:main ✓ C:0
# $

# Build the main prompt
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[cyan]%}%n) \
%{$reset_color%}@ \
%{$fg[green]%}%m \
%{$reset_color%}in \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${venv_info}\
${python_info}\
${node_info}\
${go_info}\
${git_info}\
${exit_code}
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}"

# =============================================================================
# Additional Configuration
# =============================================================================

# Enable prompt substitution for dynamic content
setopt PROMPT_SUBST

# Optional: Add right prompt with additional info
# RPROMPT='%{$fg[blue]%}%T%{$reset_color%}'

# =============================================================================
# Theme Information
# =============================================================================

# Theme name for identification
ZSH_THEME_NAME="chussenot"

# =============================================================================
# Customization Guide
# =============================================================================

# To customize this theme, set these variables in your .zshrc BEFORE sourcing the theme:
#
# # Disable certain features
# export CT_SHOW_EXIT_CODE=false
# export CT_SHOW_TIMESTAMP=false
# export CT_SHOW_VENV=false
# export CT_SHOW_VCS=false
# export CT_SHOW_PYTHON=false
# export CT_SHOW_NODE=false
# export CT_SHOW_GO=false
#
# # Use simple symbols instead of fancy ones
# export CT_VCS_SYMBOLS=false
#
# # Example minimal configuration:
# export CT_SHOW_TIMESTAMP=false
# export CT_VCS_SYMBOLS=false
# ZSH_THEME="chussenot"
#
# # Example development configuration:
# export CT_SHOW_PYTHON=true
# export CT_SHOW_NODE=true
# export CT_SHOW_GO=true
# ZSH_THEME="chussenot"