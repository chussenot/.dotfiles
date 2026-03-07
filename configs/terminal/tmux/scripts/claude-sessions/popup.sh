#!/usr/bin/env bash
# popup.sh -- launched inside the tmux popup.
# Runs picker.py through fzf, then calls open.sh with the selection.

# display-popup uses a minimal env; activate mise so python3/fzf are in PATH
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash 2>/dev/null)"
elif [ -f "${HOME}/.local/bin/mise" ]; then
  eval "$("${HOME}/.local/bin/mise" activate bash 2>/dev/null)"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

selected=$(python3 "$SCRIPT_DIR/picker.py" |
  fzf \
    --ansi \
    --delimiter='\t' \
    --with-nth=1 \
    --nth=1 \
    --no-sort \
    --layout=reverse \
    --border=rounded \
    --border-label=" Claude Sessions " \
    --border-label-pos=2 \
    --prompt="  " \
    --pointer=">" \
    --header="  enter: open   esc: cancel   J/K: scroll preview   g/G: top/bottom" \
    --preview="PATH=\"$PATH\" python3 $SCRIPT_DIR/preview.py {2} {3}" \
    --preview-window="right:45%:wrap" \
    --bind="ctrl-j:down,ctrl-k:up" \
    --bind="J:preview-down,K:preview-up" \
    --bind="ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" \
    --bind="ctrl-f:preview-page-down,ctrl-b:preview-page-up" \
    --bind="g:preview-top,G:preview-bottom" \
    --bind="/:toggle-preview" \
    2>/dev/null |
  awk -F'\t' '{print $2"\t"$3}')

[ -z "$selected" ] && exit 0
dir=$(printf '%s' "$selected" | cut -f1)
[ -z "$dir" ] && exit 0

bash "$SCRIPT_DIR/open.sh" "$selected"
