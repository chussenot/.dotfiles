# shellcheck shell=bash disable=SC2142,SC2139,SC2154,SC2168
# Kubernetes aliases — only defined when kubectl is installed.

if command -v kubectl &>/dev/null; then
  alias k='kubectl'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
  alias kx='kubectl exec -it'
fi
