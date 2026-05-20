#!/bin/sh

# Monitor Docker build progress.
# POSIX-compliant version.
#
# Usage:
#   .tests/monitor-build.sh                # defaults to ubuntu-24-04
#   .tests/monitor-build.sh alpine
#   .tests/monitor-build.sh fedora-41

set -eu

_distro="${1:-ubuntu-24-04}"
_log_file="/tmp/docker-build-dotfiles-test-${_distro}.log"

if [ ! -f "${_log_file}" ]; then
  printf 'Build log not found: %s\n' "${_log_file}"
  printf 'The build may not have started yet, or the distro slug is wrong.\n'
  printf 'Existing logs:\n'
  _found=0
  for _f in /tmp/docker-build-dotfiles-test-*.log; do
    [ -f "${_f}" ] || continue
    printf '  %s\n' "${_f}"
    _found=1
  done
  [ "${_found}" -eq 0 ] && printf '  (none)\n'
  exit 1
fi

printf 'Monitoring Docker build progress for %s...\n' "${_distro}"
printf 'Press Ctrl+C to stop monitoring\n'
printf 'Log file: %s\n\n' "${_log_file}"

# Show last 20 lines and then follow
tail -20 "${_log_file}"
printf '\n--- Following build progress (Ctrl+C to stop) ---\n\n'
tail -f "${_log_file}"
