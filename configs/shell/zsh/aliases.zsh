# shellcheck shell=bash disable=SC1090,SC2142,SC2139,SC2154,SC2168
# Zsh alias loader.
#
# Alias definitions live in ~/.zsh/aliases.d/*.zsh (symlinked from
# configs/shell/zsh/aliases.d/). Files are sourced in alphabetical order,
# so the numeric prefixes (10-, 20-, …) control load order:
#
#   10-core.zsh        navigation, list, git, dev, system, utility, safety
#   20-docker.zsh      docker basic + advanced ops + image-runner tooling
#   30-kubernetes.zsh  kubectl shortcuts (only if kubectl is installed)
#   50-sysadmin.zsh    sysadmin one-liners, tmux helpers, search, etc.
#   60-hacking.zsh     recon / capture / fuzz helpers
#
# Drop a new file into ~/.zsh/aliases.d/ and it'll be picked up on next shell.

if [[ -d "${HOME}/.zsh/aliases.d" ]]; then
  for _al_file in "${HOME}/.zsh/aliases.d"/*.zsh(N); do
    source "${_al_file}"
  done
  unset _al_file
fi
