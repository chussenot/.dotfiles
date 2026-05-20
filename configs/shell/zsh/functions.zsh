# shellcheck shell=bash disable=SC1090
# Zsh function loader.
#
# Function definitions live in ~/.zsh/functions.d/*.zsh (symlinked from
# configs/shell/zsh/functions.d/). Files are sourced in alphabetical order,
# so the numeric prefixes (10-, 20-, …, 90-) control load order:
#
#   10-fs.zsh          file / directory helpers
#   20-git.zsh         git helpers
#   30-dev.zsh         language tooling, system info, API helpers
#   40-containers.zsh  docker + kubernetes helpers
#   50-tmux.zsh        tmux helpers
#   60-zsh-utils.zsh   compdef, reload, zshconfig, alias inspector
#   80-update.zsh      `update` orchestrator + per-tool helpers + krew-sync
#   90-sudo.zsh        Esc-Esc sudo toggle widget — must load last so zle
#                      widgets registered above are still in place.
#
# Drop a new file into ~/.zsh/functions.d/ and it'll be picked up on next shell.

if [[ -d "${HOME}/.zsh/functions.d" ]]; then
  for _fn_file in "${HOME}/.zsh/functions.d"/*.zsh(N); do
    source "${_fn_file}"
  done
  unset _fn_file
fi
