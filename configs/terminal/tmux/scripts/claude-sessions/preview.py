#!/usr/bin/env python3
"""
preview.py -- fzf preview pane for Claude session browser.

Called by fzf as:  preview.py <path> <session-id>

Renders the conversation from the .jsonl file with colored role badges.
"""

import json
import os
import sys
import textwrap
from pathlib import Path

CLAUDE_PROJECTS = (
    Path(os.environ.get("CLAUDE_SESSIONS_DIR", "")).expanduser()
    if os.environ.get("CLAUDE_SESSIONS_DIR")
    else Path.home() / ".claude" / "projects"
)

CYAN = "\033[38;5;45m"
MAGENTA = "\033[38;5;201m"
GRAY = "\033[38;5;242m"
GREEN = "\033[38;5;84m"
WHITE = "\033[38;5;252m"
RESET = "\033[0m"


def col(s, c):
    return f"{c}{s}{RESET}"


def main():
    if len(sys.argv) < 3:
        print("No session selected.")
        return

    dir_path = Path(sys.argv[1].strip())
    sid = sys.argv[2].strip()
    home = Path.home()

    # Locate the .jsonl file
    try:
        rel = dir_path.relative_to("/")
        encoded = "-" + str(rel).replace("/", "-").replace(".", "-")
    except Exception:
        encoded = ""

    jsonl = None
    for p in CLAUDE_PROJECTS.iterdir():
        if encoded and (p.name == encoded or p.name.startswith(encoded)):
            candidate = p / f"{sid}.jsonl"
            if candidate.exists():
                jsonl = candidate
                break

    if not jsonl:
        for p in CLAUDE_PROJECTS.iterdir():
            candidate = p / f"{sid}.jsonl"
            if candidate.exists():
                jsonl = candidate
                break

    if not jsonl:
        print(col(f"Session file not found: {sid}", MAGENTA))
        return

    short_dir = str(dir_path).replace(str(home), "~")
    print(col(f" {short_dir}", CYAN))
    print(col(f" {sid[:8]}\u2026", GRAY))
    print()

    try:
        with open(jsonl) as f:
            lines = [json.loads(line) for line in f if line.strip()]
    except Exception as e:
        print(f"Error reading session: {e}")
        return

    for d in lines:
        role = d.get("type")
        if role not in ("user", "assistant"):
            continue

        content = d.get("message", {}).get("content", [])
        texts = []
        if isinstance(content, str):
            texts = [content]
        elif isinstance(content, list):
            texts = [
                c["text"]
                for c in content
                if isinstance(c, dict) and c.get("type") == "text"
            ]

        for text in texts:
            text = text.strip()
            if not text or text.startswith("<"):
                continue

            if role == "user":
                badge = col("  you  ", f"\033[48;5;18m{CYAN}")
            else:
                badge = col(" claude ", f"\033[48;5;22m{GREEN}")

            wrapped = textwrap.fill(text, width=42, subsequent_indent="         ")
            print(f"{badge} {WHITE}{wrapped}{RESET}")
            print()


if __name__ == "__main__":
    main()
