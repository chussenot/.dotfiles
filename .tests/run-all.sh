#!/bin/sh

# Docker Test Harness for POSIX Installer
# POSIX-compliant version
#
# This script builds and tests the dotfiles installer in Docker containers.
# It validates that the installer works correctly in a clean environment.
#
# Usage:
#   ./.tests/run-all.sh
#
# CI Integration Examples:
#
# GitHub Actions:
#   - name: Test dotfiles installer
#     run: ./.tests/run-all.sh
#
# GitLab CI:
#   test_installer:
#     script:
#       - ./.tests/run-all.sh
#
# CircleCI:
#   - run:
#       name: Test installer
#       command: ./.tests/run-all.sh

set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

_print_status() {
    printf '%b[INFO]%b %s\n' "${BLUE}" "${NC}" "$1"
}

_print_success() {
    printf '%b[PASS]%b %s\n' "${GREEN}" "${NC}" "$1"
}

_print_error() {
    printf '%b[FAIL]%b %s\n' "${RED}" "${NC}" "$1"
}

_print_warning() {
    printf '%b[WARN]%b %s\n' "${YELLOW}" "${NC}" "$1"
}

# Get the directory where this script is located
_get_script_dir() {
    _script_path="$0"
    _script_dir=""
    case "${_script_path}" in
        /*)
            _script_dir=$(dirname "${_script_path}")
            ;;
        *)
            _script_dir=$(cd "$(dirname "${_script_path}")" && pwd)
            ;;
    esac
    printf '%s\n' "${_script_dir}"
}

_script_dir=$(_get_script_dir)
_project_root=$(cd "${_script_dir}/.." && pwd)
_docker_dir="${_script_dir}/docker"

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    _print_error "Docker is not installed or not in PATH"
    _print_error "Please install Docker to run the test harness"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
    _print_error "Docker daemon is not running"
    _print_error "Please start Docker to run the test harness"
    exit 1
fi

_print_status "Starting Docker test harness..."
_print_status "Project root: ${_project_root}"
_print_status "Docker directory: ${_docker_dir}"
printf '\n'

# Find all Dockerfiles in the docker directory
_total=0
_passed=0
_failed=0

_print_status "Scanning for Dockerfiles..."
for _dockerfile in "${_docker_dir}"/*.Dockerfile; do
    if [ ! -f "${_dockerfile}" ]; then
        continue
    fi

    _total=$((_total + 1))
    _dockerfile_name=$(basename "${_dockerfile}")
    _image_name=$(printf '%s' "${_dockerfile_name}" | sed 's/\.Dockerfile$//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    _image_name="dotfiles-test-${_image_name}"

    _print_status "Building ${_dockerfile_name}..."
    _print_status "Image name: ${_image_name}"

    # Build the Docker image
    if docker build \
        -f "${_dockerfile}" \
        -t "${_image_name}" \
        "${_project_root}" >"/tmp/docker-build-${_image_name}.log" 2>&1; then
        _print_success "Build succeeded: ${_dockerfile_name}"
        _passed=$((_passed + 1))
    else
        _print_error "Build failed: ${_dockerfile_name}"
        _print_error "Build log saved to: /tmp/docker-build-${_image_name}.log"
        _print_error "Last 20 lines of build log:"
        tail -20 "/tmp/docker-build-${_image_name}.log" | sed 's/^/  /'
        _failed=$((_failed + 1))
    fi
    printf '\n'
done

# Summary
printf '\n'
_print_status "=== Test Summary ==="
printf 'Total Dockerfiles: %d\n' "${_total}"
_print_success "Passed: ${_passed}"
if [ "${_failed}" -gt 0 ]; then
    _print_error "Failed: ${_failed}"
fi

if [ "${_failed}" -eq 0 ] && [ "${_total}" -gt 0 ]; then
    printf '\n'
    _print_success "All tests passed!"
    exit 0
elif [ "${_total}" -eq 0 ]; then
    _print_warning "No Dockerfiles found in ${_docker_dir}"
    exit 1
else
    printf '\n'
    _print_error "Some tests failed"
    exit 1
fi
