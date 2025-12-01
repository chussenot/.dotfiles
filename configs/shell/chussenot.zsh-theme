# Chussenot Zsh Theme
# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Refactored for better maintainability and performance
#
# Color scheme aligned with tmux configuration:
# - Cyan: Username, VCS info, active elements (matches tmux status bar, active borders)
# - Green: Hostname, success states, clean VCS (matches tmux green)
# - Yellow: Directory, warnings, jobs (matches tmux yellow messages)
# - Red: Errors, exit codes, dirty VCS (matches tmux error styling)
# - Black: Background (matches tmux black background)
# - White: Default text (matches tmux white text)

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
: ${CT_SHOW_LOAD:=true}
: ${CT_SHOW_JOBS:=true}
: ${CT_SHOW_DOCKER:=true}
: ${CT_SHOW_KUBECTL:=false}

# VCS (Version Control System) styling
# Aligned with tmux: cyan for info elements (matches tmux status bar)
CT_VCS_PREFIX=" %{$reset_color%}on%{$fg[cyan]%} "
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

# System load styling
CT_LOAD_PREFIX=" %{$fg[magenta]%}load:"
CT_LOAD_SUFFIX="%{$reset_color%}"

# Background jobs styling
CT_JOBS_PREFIX=" %{$fg[yellow]%}jobs:"
CT_JOBS_SUFFIX="%{$reset_color%}"

# Docker styling (aligned with tmux: cyan for info elements)
CT_DOCKER_PREFIX=" %{$fg[cyan]%}🐳"
CT_DOCKER_SUFFIX="%{$reset_color%}"


# =============================================================================
# VCS Prompt Functions
# =============================================================================

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="${CT_VCS_PREFIX}git${CT_VCS_SEPARATOR}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$CT_VCS_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$CT_VCS_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$CT_VCS_CLEAN"

# Standalone git_prompt_info function (works without Oh-My-Zsh)
git_prompt_info() {
    # Check if git is available
    command -v git >/dev/null 2>&1 || return

    # Check if we're in a git repository
    git rev-parse --git-dir >/dev/null 2>&1 || return

    # Get branch name
    local ref
    ref=$(git symbolic-ref HEAD 2>/dev/null) || ref=$(git rev-parse --short HEAD 2>/dev/null) || return

    # Remove 'refs/heads/' prefix
    ref=${ref#refs/heads/}

    # Check if working directory is dirty
    local dirty=""
    if ! git diff --quiet --ignore-submodules --cached 2>/dev/null || \
       ! git diff-files --quiet --ignore-submodules 2>/dev/null; then
        dirty="${CT_VCS_DIRTY}"
    else
        dirty="${CT_VCS_CLEAN}"
    fi

    # Build and return the prompt string
    echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref}${dirty}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

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
# System Load Function
# =============================================================================

system_load() {
    # Check if system load should be shown
    [[ "$CT_SHOW_LOAD" == "true" ]] || return

    # Get 1-minute load average
    local load_avg
    load_avg=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' ') || return

    # Color code based on load (green < 1, yellow < 2, red >= 2)
    if (( $(echo "$load_avg < 1" | bc -l 2>/dev/null || echo "0") )); then
        echo "${CT_LOAD_PREFIX}%{$fg[green]%}${load_avg}%{$reset_color%}${CT_LOAD_SUFFIX}"
    elif (( $(echo "$load_avg < 2" | bc -l 2>/dev/null || echo "0") )); then
        echo "${CT_LOAD_PREFIX}%{$fg[yellow]%}${load_avg}%{$reset_color%}${CT_LOAD_SUFFIX}"
    else
        echo "${CT_LOAD_PREFIX}%{$fg[red]%}${load_avg}%{$reset_color%}${CT_LOAD_SUFFIX}"
    fi
}

# =============================================================================
# Background Jobs Function
# =============================================================================

background_jobs() {
    # Check if background jobs should be shown
    [[ "$CT_SHOW_JOBS" == "true" ]] || return

    local job_count
    job_count=$(jobs -r | wc -l 2>/dev/null) || return

    # Only show if there are background jobs
    if [[ $job_count -gt 0 ]]; then
        echo "${CT_JOBS_PREFIX}${job_count}${CT_JOBS_SUFFIX}"
    fi
}

# =============================================================================
# Docker Function
# =============================================================================

docker_info() {
    # Check if Docker info should be shown
    [[ "$CT_SHOW_DOCKER" == "true" ]] || return

    # Check if Docker is available and running
    command -v docker >/dev/null 2>&1 || return
    docker info >/dev/null 2>&1 || return

    # Check if we're in a Docker container
    if [[ -f /.dockerenv ]] || [[ -n "${DOCKER_CONTAINER:-}" ]]; then
        echo "${CT_DOCKER_PREFIX}${CT_DOCKER_SUFFIX}"
    fi
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

# System load info (only if enabled)
if [[ "$CT_SHOW_LOAD" == "true" ]]; then
    local load_info='$(system_load)'
else
    local load_info=''
fi

# Background jobs info (only if enabled)
if [[ "$CT_SHOW_JOBS" == "true" ]]; then
    local jobs_info='$(background_jobs)'
else
    local jobs_info=''
fi

# Docker info (only if enabled)
if [[ "$CT_SHOW_DOCKER" == "true" ]]; then
    local docker_info='$(docker_info)'
else
    local docker_info=''
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
# PRIVILEGES USER @ MACHINE in DIRECTORY py:VERSION node:VERSION go:VERSION load:LOAD jobs:JOBS 🐳 on git:BRANCH STATE C:EXIT_CODE
# $ COMMAND
#
# Example:
# # chussenot @ hostname in ~/.dotfiles py:3.11 node:18.17 go:1.21 load:0.5 jobs:2 🐳 on git:main ✓ C:0
# $

# Build the main prompt
# Color scheme aligned with tmux:
# - Cyan: username, VCS info (matches tmux status bar cyan)
# - Green: hostname, success states (matches tmux green)
# - Yellow: directory, warnings (matches tmux yellow messages)
# - Red: errors, exit codes (matches tmux error styling)
# - Blue: prompt symbol (distinct from cyan for hierarchy)
PROMPT="
%{$terminfo[bold]$fg[cyan]%}#%{$reset_color%} \
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[cyan]%}%n) \
%{$reset_color%}@ \
%{$fg[green]%}%m \
%{$reset_color%}in \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${venv_info}\
${python_info}\
${node_info}\
${go_info}\
${load_info}\
${jobs_info}\
${docker_info}\
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
# export CT_SHOW_LOAD=false
# export CT_SHOW_JOBS=false
# export CT_SHOW_DOCKER=false
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
# export CT_SHOW_LOAD=true
# export CT_SHOW_JOBS=true
# ZSH_THEME="chussenot"
#
# # Example DevOps configuration:
# export CT_SHOW_DOCKER=true
# export CT_SHOW_LOAD=true
# ZSH_THEME="chussenot"
