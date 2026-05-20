# shellcheck shell=bash disable=SC1090,SC2155,SC2164
# Tmux helpers.

# Open / attach a 3-pane "dev" tmux session
tdev() {
    if ! command -v tmux &>/dev/null; then
        echo "Error: tmux is not installed" >&2
        return 1
    fi

    if tmux has-session -t dev 2>/dev/null; then
        tmux attach-session -t dev
    else
        tmux new-session -s dev -d
        tmux split-window -h
        tmux split-window -v
        tmux select-pane -t 0
        tmux attach-session -t dev
    fi
}
