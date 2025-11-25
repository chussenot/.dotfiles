#!/bin/sh

# Monitor Docker build progress
# POSIX-compliant version

set -eu

_log_file="/tmp/docker-build-dotfiles-test-ubuntu-24-04.log"

if [ ! -f "${_log_file}" ]; then
    printf 'Build log not found: %s\n' "${_log_file}"
    printf 'The build may not have started yet.\n'
    exit 1
fi

printf 'Monitoring Docker build progress...\n'
printf 'Press Ctrl+C to stop monitoring\n'
printf 'Log file: %s\n\n' "${_log_file}"

# Show last 20 lines and then follow
tail -20 "${_log_file}"
printf '\n--- Following build progress (Ctrl+C to stop) ---\n\n'
tail -f "${_log_file}"
