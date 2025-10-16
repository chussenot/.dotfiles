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
: ${CT_SHOW_TIMESTAMP:=true}
: ${CT_SHOW_VENV:=true}
: ${CT_SHOW_VCS:=true}
: ${CT_VCS_SYMBOLS:=true}

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

# =============================================================================
# VCS Prompt Functions
# =============================================================================

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="${CT_VCS_PREFIX}git${CT_VCS_SEPARATOR}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$CT_VCS_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$CT_VCS_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$CT_VCS_CLEAN"

# SVN prompt configuration
ZSH_THEME_SVN_PROMPT_PREFIX="${CT_VCS_PREFIX}svn${CT_VCS_SEPARATOR}"
ZSH_THEME_SVN_PROMPT_SUFFIX="$CT_VCS_SUFFIX"
ZSH_THEME_SVN_PROMPT_DIRTY="$CT_VCS_DIRTY"
ZSH_THEME_SVN_PROMPT_CLEAN="$CT_VCS_CLEAN"

# Mercurial (Hg) prompt function
hg_prompt_info() {
    # Check if VCS should be shown
    [[ "$CT_SHOW_VCS" == "true" ]] || return
    
    # Check if we're in a mercurial repository
    [[ -d '.hg' ]] || return
    
    local hg_branch
    hg_branch=$(hg branch 2>/dev/null) || return
    
    echo -n "${CT_VCS_PREFIX}hg${CT_VCS_SEPARATOR}${hg_branch}"
    
    # Check if dirty status should be shown
    if [[ "$(hg config oh-my-zsh.hide-dirty 2>/dev/null)" != "1" ]]; then
        if hg status -q 2>/dev/null | grep -q .; then
            echo -n "$CT_VCS_DIRTY"
        else
            echo -n "$CT_VCS_CLEAN"
        fi
    fi
    
    echo -n "$CT_VCS_SUFFIX"
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
# Prompt Variables (for performance)
# =============================================================================

# Pre-compute VCS info for better performance (only if enabled)
if [[ "$CT_SHOW_VCS" == "true" ]]; then
    local git_info='$(git_prompt_info)'
    local svn_info='$(svn_prompt_info)'
    local hg_info='$(hg_prompt_info)'
else
    local git_info=''
    local svn_info=''
    local hg_info=''
fi

# Virtual environment info (only if enabled)
if [[ "$CT_SHOW_VENV" == "true" ]]; then
    local venv_info='$(virtualenv_prompt)'
else
    local venv_info=''
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
# PRIVILEGES USER @ MACHINE in DIRECTORY on vcs:BRANCH STATE [TIME] C:EXIT_CODE
# $ COMMAND
#
# Example:
# # chussenot @ hostname in ~/.dotfiles on git:main ✓ [14:30:25] C:0
# $

# Build the main prompt
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[cyan]%}%n) \
%{$reset_color%}@ \
%{$fg[green]%}%m \
%{$reset_color%}in \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${hg_info}\
${git_info}\
${svn_info}\
${venv_info}\
 \
$([ "$CT_SHOW_TIMESTAMP" = "true" ] && echo "[%*]")${exit_code}
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
#
# # Use simple symbols instead of fancy ones
# export CT_VCS_SYMBOLS=false
#
# # Example minimal configuration:
# export CT_SHOW_TIMESTAMP=false
# export CT_VCS_SYMBOLS=false
# ZSH_THEME="chussenot"