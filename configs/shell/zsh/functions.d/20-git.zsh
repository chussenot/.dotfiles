# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# Git helper functions.

# git add . && commit -m "<msg>"
gac() {
    if [[ -z "$1" ]]; then
        echo "Usage: gac <commit-message>" >&2
        return 1
    fi
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    git add . && git commit -m "$1"
}

# git add . && commit -m "<msg>" && push
gacp() {
    if [[ -z "$1" ]]; then
        echo "Usage: gacp <commit-message>" >&2
        return 1
    fi
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    git add . && git commit -m "$1" && git push
}

# Push current branch and set upstream in one step
gpu() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -z "$branch" ]]; then
        echo "Error: Not on a branch" >&2
        return 1
    fi
    git push --set-upstream origin "$branch"
}

# Quick git status (function rather than alias so it can validate the repo)
function gst() {
    if git rev-parse --git-dir &>/dev/null; then
        git status
    else
        echo "Error: Not in a git repository" >&2
        return 1
    fi
}
