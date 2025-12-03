############################
# Zsh Configuration
############################

# Initialize colors module (required for theme colors)
autoload -Uz colors && colors

# Load aliases
if [[ -f "$HOME/.zsh/aliases.zsh" ]]; then
  source "$HOME/.zsh/aliases.zsh"
fi

# Load functions
if [[ -f "$HOME/.zsh/functions.zsh" ]]; then
  source "$HOME/.zsh/functions.zsh"
fi

# >>> Fast completions (static, cached)
source "$HOME/.zsh/_completions.zsh"
# <<< Fast completions

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
# Note: History-related setopt are defined in the "Zsh Shell Options" section below

############################
# Tmux Session Management
############################

# Check if we are inside a tmux session
# Only auto-start tmux if it's available and we're in an interactive shell
if [[ -z "$TMUX" && -n "$PS1" && -t 0 ]] && command -v tmux &>/dev/null; then
  # Try to attach to an existing session 'default' if it exists
  # Otherwise create a new session named 'default'
  if ! tmux attach-session -t default 2>/dev/null; then
    tmux new-session -s default 2>/dev/null || {
      echo "⚠️  Warning: Failed to start tmux session" >&2
    }
  fi
fi

############################
# General Environment Variables
############################

# ENABLE_WASM is intentionally empty (unset if needed)
# export ENABLE_WASM=

# Shell identification (interactive shell specific)
readonly SHELL='/usr/bin/zsh'

# Set dotfiles directory for easy access (interactive shell specific)
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Note: System-wide environment variables (EDITOR, VISUAL, PAGER, LESS, LC_CTYPE, LANG, TZ, XDG_*)
# have been moved to .zshenv to be available for all shell invocations

############################
# PATH Management
############################
# Note: PATH additions have been moved to .zshenv to be available for all shell invocations
# Mise shims are added automatically by mise activate

############################
# Zsh Shell Options (setopt/unsetopt)
############################
# This section centralizes all shell behavior modifications.
# All options are documented to clearly show what differs from zsh defaults.

# History behavior
# - INC_APPEND_HISTORY_TIME: Append history immediately with timestamps (better than SHARE_HISTORY)
# - HIST_EXPIRE_DUPS_FIRST: Expire duplicates first when trimming history
# - HIST_FCNTL_LOCK: Use fcntl() for better file locking on modern systems
# - EXTENDED_HISTORY: Save timestamps and duration in history
# - HIST_IGNORE_DUPS: Don't record duplicate entries
# - HIST_FIND_NO_DUPS: Don't display duplicates when searching history
# - HIST_IGNORE_SPACE: Don't record commands starting with space
# - HIST_VERIFY: Show command with history expansion before running
# - HIST_SAVE_NO_DUPS: Don't write duplicate entries to history file
setopt INC_APPEND_HISTORY_TIME
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_SAVE_NO_DUPS

# Navigation behavior
# - AUTO_CD: Type directory name to cd into it
# - AUTO_PUSHD: Make cd push the old directory onto the directory stack
# - PUSHD_SILENT: Don't print the directory stack after pushd/popd
# - PUSHD_IGNORE_DUPS: Don't push duplicate directories onto the stack
# - CDABLE_VARS: Allow cd to variables (e.g., cd $HOME)
# - COMPLETE_IN_WORD: Complete from both ends of the word
# - AUTO_LIST: Automatically list choices on ambiguous completion
# - AUTO_MENU: Show completion menu on second tab
# - LIST_PACKED: Use compact completion lists
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_SILENT
setopt PUSHD_IGNORE_DUPS
setopt CDABLE_VARS
setopt COMPLETE_IN_WORD
setopt AUTO_LIST
setopt AUTO_MENU
setopt LIST_PACKED

# Globbing and pattern matching
# - EXTENDED_GLOB: Enable extended globbing patterns (#, ~, ^)
# - NOMATCH: Print error if globbing fails to match
setopt EXTENDED_GLOB
setopt NOMATCH

# Command correction
# - CORRECT: Try to correct spelling of commands
# - CORRECT_ALL: Try to correct all arguments
# Note: Disabled as they interfere with legitimate commands (e.g., kubectl config)
unsetopt CORRECT
unsetopt CORRECT_ALL

# Disable annoying behaviors
# - BEEP: Disable terminal bell/beep
# - HIST_BEEP: Don't beep when accessing non-existent history entries
# - FLOW_CONTROL: Disable flow control (Ctrl+S/Ctrl+Q)
# - MAIL_WARNING: Don't print warning if mail file has been accessed
unsetopt BEEP
unsetopt HIST_BEEP
unsetopt FLOW_CONTROL
unsetopt MAIL_WARNING

############################
# Language and Runtime Settings
############################

# Mise en place
export MISE_HOME="$HOME/.mise"
# Only activate mise if it exists and the activation script is available
if [[ -f ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)" 2>/dev/null || {
    echo "⚠️  Warning: mise activation failed" >&2
  }
elif command -v mise &>/dev/null; then
  eval "$(mise activate zsh)" 2>/dev/null || {
    echo "⚠️  Warning: mise activation failed" >&2
  }
fi

############################
# Antidote Plugin Manager
############################

# Install Antidote if not present
if [[ ! -d ${ZDOTDIR:-$HOME}/.antidote ]]; then
    if ! command -v git &>/dev/null; then
        echo "⚠️  Warning: git is required to install Antidote" >&2
    else
        print -P "%F{33}Installing %F{220}Antidote %F{33}Plugin Manager...%f"
        command git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote && \
            print -P "%F{33}✓ %F{34}Installation successful.%f" || \
            print -P "%F{160}✗ Installation failed.%f"
    fi
fi

# Load Antidote
if [[ -f ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh ]]; then
    source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
else
    echo "⚠️  Warning: Antidote not found. Some plugins may not work." >&2
fi

# Initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

############################
# Completion System
############################

# Completion styling (compinit is handled by _completions.zsh)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completion performance and behavior improvements
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact-dirs true

############################
# Antidote Plugins
############################
# Plugins are managed via ${ZDOTDIR:-~}/.zsh_plugins.txt
# Run 'antidote bundle' to regenerate the static plugin file after editing

# Custom fzf history search (replaces plugin)
fzf-history-widget() {
  # Only define if fzf is available
  if ! command -v fzf &>/dev/null; then
    return 1
  fi

  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

  # Use __fzfcmd if available, otherwise use fzf directly
  local fzf_cmd="${__fzfcmd:-fzf}"

  selected=( $(fc -rl 1 | awk '!seen[$0]++' | grep -v -E '(nim|data)' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tac -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(q)LBUFFER} +m" $fzf_cmd) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
# Note: fzf-history-widget is defined but not bound by default
# Uncomment the line below to enable it (conflicts with atuin's Ctrl+R)
# bindkey '^R' fzf-history-widget

############################
# Key Bindings
############################

# Navigation and history search

bindkey '^[[A' history-substring-search-up # Up arrow: search backward in history for matching substring
bindkey '^[[B' history-substring-search-down # Down arrow: search forward in history for matching substring
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# Additional useful keybindings
bindkey '^U' backward-kill-line   # Ctrl+U: kill from cursor to beginning of line (bash-like)
bindkey '^[[3~' delete-char       # Delete key: delete character under cursor
bindkey '^[[1~' beginning-of-line  # Home key: go to beginning of line
bindkey '^[[4~' end-of-line       # End key: go to end of line

############################
# Local Configuration
############################

# Load local Zsh configurations from ~/.zsh.local
if [[ -d "$HOME/.zsh.local" ]]; then
  for file in "$HOME/.zsh.local"/*.zsh; do
    [[ -f "$file" ]] && source "$file"
  done
fi

# Note: PATH additions (including Krew) have been moved to .zshenv

############################
# Fuzzy Finder & Directory Navigation
############################

# General Fuzzy finder
# Only source if fzf is installed and the file exists
if command -v fzf &>/dev/null && [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

############################
# Theme Loading
############################

# Load chussenot theme (standalone, no Oh-My-Zsh required)
if [[ -f "$HOME/.zsh/themes/chussenot.zsh-theme" ]]; then
    source "$HOME/.zsh/themes/chussenot.zsh-theme"
elif [[ -f "$DOTFILES_DIR/configs/shell/chussenot.zsh-theme" ]]; then
    source "$DOTFILES_DIR/configs/shell/chussenot.zsh-theme"
fi

############################
# Atuin
############################

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

############################
# zoxide
############################

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Note: bashcompinit is already handled in _completions.zsh
# Note: MANPATH has been moved to .zshenv to be available for all shell invocations

############################
# Performance Profiling (optional)
############################
# Uncomment to profile zsh startup time
# Uncomment the lines below and run: zsh -i -c exit
# zmodload zsh/zprof
# zprof
