# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# Docker and Kubernetes helpers.

# Prune all docker resources
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

# Kubernetes pod port-forward, picked via fzf
kpf() {
  if ! command -v kubectl &>/dev/null; then
    echo "Error: kubectl is not installed" >&2
    return 1
  fi
  local ns="${1:---all-namespaces}"
  local resource
  if [[ "$ns" == "--all-namespaces" ]]; then
    resource=$(kubectl get pods --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase' --no-headers | fzf --prompt="pod> ")
  else
    resource=$(kubectl get pods -n "$ns" -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase' --no-headers | fzf --prompt="pod> ")
  fi
  [[ -z "$resource" ]] && return 0
  local pod_ns=$(echo "$resource" | awk '{print $1}')
  local pod=$(echo "$resource" | awk '{print $2}')
  local ports
  ports=$(kubectl get pod -n "$pod_ns" "$pod" -o jsonpath='{range .spec.containers[*].ports[*]}{.containerPort}{"\n"}{end}' | sort -u | fzf --prompt="port> ")
  [[ -z "$ports" ]] && return 0
  local local_port
  read -r "local_port?Local port [$ports]: "
  local_port="${local_port:-$ports}"
  echo "Forwarding localhost:$local_port -> $pod:$ports in $pod_ns"
  kubectl port-forward -n "$pod_ns" "pod/$pod" "$local_port:$ports"
}
