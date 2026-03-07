#!/usr/bin/env python3
"""
picker.py -- lists all Claude CLI sessions for fzf consumption.

Scans ~/.claude/projects/, decodes the hyphen-encoded directory names
back to real filesystem paths, and emits one tab-delimited line per session:

    <display-text>\t<real-path>\t<session-id>

fzf shows only column 1; columns 2-3 are hidden payload for preview/open.
"""

import json
import os
import sys
import time
from pathlib import Path

CLAUDE_PROJECTS = (
    Path(os.environ.get("CLAUDE_SESSIONS_DIR", "")).expanduser()
    if os.environ.get("CLAUDE_SESSIONS_DIR")
    else Path.home() / ".claude" / "projects"
)

# ANSI colors
CYAN = "\033[38;5;45m"
MAGENTA = "\033[38;5;201m"
GRAY = "\033[38;5;242m"
WHITE = "\033[38;5;252m"
RESET = "\033[0m"


def col(s, c):
    return f"{c}{s}{RESET}"


def decode_project_dir(encoded):
    """Reverse Claude CLI's path encoding (/ -> -, . -> --)."""
    raw = encoded.lstrip("-").replace("--", "-\x00")
    parts = []
    for token in raw.split("-"):
        if token.startswith("\x00"):
            parts.append("." + token[1:])
        elif token:
            parts.append(token)

    def match(base, tokens):
        if not tokens:
            return base
        for width in range(1, len(tokens) + 1):
            component = "-".join(tokens[:width])
            candidate = base / component
            if candidate.exists():
                result = match(candidate, tokens[width:])
                if result is not None:
                    return result
        return None

    result = match(Path("/"), parts)
    if result is not None:
        return result
    return Path("/") / "/".join(parts) if parts else None


def first_message(jsonl):
    """Extract the first real user message from a session file."""
    try:
        with open(jsonl) as f:
            for line in f:
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                if d.get("type") != "user":
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
                    t = text.strip()
                    if t and not t.startswith("<"):
                        return " ".join(t.split())
    except Exception:
        pass
    return ""


def age(mtime):
    s = int(time.time() - mtime)
    if s < 3600:
        return f"{s // 60}m"
    if s < 86400:
        return f"{s // 3600}h"
    return f"{s // 86400}d"


def main():
    if not CLAUDE_PROJECTS.exists():
        print("No claude projects directory found.", file=sys.stderr)
        sys.exit(1)

    home = Path.home()
    groups = []

    for p in sorted(CLAUDE_PROJECTS.iterdir()):
        if not p.is_dir():
            continue
        convs = []
        for f in p.glob("*.jsonl"):
            if f.stem.startswith("agent-"):
                continue
            if not first_message(f):
                continue
            convs.append((f.stat().st_mtime, f))
        if not convs:
            continue
        convs.sort(reverse=True)
        real = decode_project_dir(p.name)
        groups.append((convs[0][0], real, convs))

    groups.sort(reverse=True)

    for _, real, convs in groups:
        short = str(real).replace(str(home), "~") if real else "(unknown)"
        real = real or Path.home()

        count = len(convs)
        print(f"  {col(short, CYAN)}  {col(f'({count})', GRAY)}")

        for mtime, f in convs:
            sid = f.stem
            msg = first_message(f)
            a = age(mtime)
            label = (
                (msg[:58] + "\u2026")
                if len(msg) > 58
                else (msg or col("(empty)", GRAY))
            )
            age_s = col(f"[{a:>3}]", MAGENTA)
            print(f"    {age_s}  {col(label, WHITE)}\t{real}\t{sid}")


if __name__ == "__main__":
    main()
