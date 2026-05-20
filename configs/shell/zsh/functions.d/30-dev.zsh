# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# Developer helpers — language tooling, system info, API helpers.

# Datadog API helper
ddapi() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: ddapi <GET|POST|PUT|DELETE> <endpoint> [data]" >&2
    echo "Example: ddapi GET v2/users" >&2
    return 1
  fi
  local method="$1" endpoint="$2" data="$3"
  curl -s -X "$method" "https://api.datadoghq.eu/api/$endpoint" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    ${data:+-d "$data"} | jq .
}

# Memory summary (RAM + swap)
meminfo() {
    if command -v free &>/dev/null; then
        free -h | grep -E "Mem|Swap"
    else
        echo "Error: free command not found" >&2
        return 1
    fi
}

# CPU summary (model, cores, threads)
cpuinfo() {
    if command -v lscpu &>/dev/null; then
        lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
    else
        echo "Error: lscpu command not found" >&2
        return 1
    fi
}

# Create a Python venv and activate it
pyvenv() {
    if [[ -z "$1" ]]; then
        echo "Usage: pyvenv <venv-name>" >&2
        return 1
    fi
    if ! command -v python3 &>/dev/null; then
        echo "Error: python3 is not installed" >&2
        return 1
    fi
    python3 -m venv "$1" && source "$1/bin/activate" || {
        echo "Error: Failed to create virtual environment" >&2
        return 1
    }
}
