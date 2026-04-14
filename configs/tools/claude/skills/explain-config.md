# explain-config

Explain what a configuration file does in plain language.

## When to use

Use when the user asks "what does this config do?",
"explain my tmux config", "what can I remove from .zshrc?",
or any request to understand or audit a config file.

## Steps

1. **Read the target config file** completely.

2. **Break it into logical sections** and for each section explain:
   - **What it does** in plain language (one sentence)
   - **Whether it's a default or custom setting** — flag
     anything that overrides tool defaults
   - **Dependencies** — other tools, plugins, or configs
     it relies on
   - **Platform notes** — if it only applies to Linux or macOS

3. **Flag potential issues**:
   - Redundant settings (set twice, or overridden later)
   - Dead config (references tools/plugins that aren't
     installed or are commented out elsewhere)
   - Conflicting settings within the file or with other
     config files in the repo
   - Performance concerns (heavy operations in shell startup,
     synchronous evals)

4. **Identify safe removals** if the user asks about cleanup:
   - Settings that match the tool's defaults (no-ops)
   - Sections for tools no longer in `mise.toml` or the
     install scripts
   - Commented-out blocks that have been inactive for
     a long time
   - Mark each candidate as "safe to remove", "check first",
     or "keep"

5. **Format the output** as:
   - Section-by-section walkthrough with line number references
   - A summary table at the end if the file is large
     (20+ logical sections)
   - Highlight the most impactful/important settings

## Important rules

- Always read the file fresh — don't explain from memory.
- Cross-reference with other configs when relevant
  (e.g., `.zshenv` sets vars that `.zshrc` uses).
- Don't suggest changes unless the user asks for cleanup —
  this skill is primarily informational.
- Use the file:line_number format when referencing
  specific lines.
