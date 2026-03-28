#!/bin/sh
# Tmux status-right helper — outputs contextual info segments
# Called every status-interval (5s) by tmux via #()

_segments=""

# Kubernetes context (last segment of context name)
if command -v kubectl >/dev/null 2>&1; then
  _k8s_ctx="$(kubectl config current-context 2>/dev/null | awk -F_ '{print $NF}')"
  if [ -n "$_k8s_ctx" ]; then
    _segments="#[fg=yellow] ${_k8s_ctx} "
  fi
fi

printf '%s' "$_segments"
