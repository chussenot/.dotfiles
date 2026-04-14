# secure-audit

Audit dotfiles for security issues and hardening opportunities.

## When to use

Use when the user asks to check security, audit configs,
or before sharing/publishing dotfiles.

## Steps

1. **Scan for secrets and credentials** across the entire repo:
   - Grep for patterns: API keys, tokens, passwords,
     AWS keys, private keys
   - Check for `.env` files, credentials files, or secrets
     accidentally committed
   - Look for hardcoded usernames, hostnames, or IP addresses
   - Verify `.gitignore` excludes sensitive patterns
     (`.env`, `*.pem`, `id_rsa`, etc.)

2. **Audit shell configuration** — read `.zshrc`, `.zshenv`,
   `aliases.zsh`, `functions.zsh`:
   - Dangerous aliases: `alias rm='rm -rf'`,
     `alias sudo='sudo '` without understanding
   - History settings: is `HISTFILE` in a safe location?
     Is `HIST_IGNORE_SPACE` set?
   - Eval of untrusted input: `eval "$(curl ...)"`
     or similar patterns
   - PATH manipulation: writable directories early in PATH
     (`.` or relative paths)
   - Exported secrets: `export API_KEY=...` or
     `export PASSWORD=...`

3. **Audit SSH-related config** if present:
   - Overly permissive SSH agent forwarding
   - Weak key types or missing key restrictions
   - Permissive known_hosts settings
     (`StrictHostKeyChecking no`)

4. **Audit Git configuration**:
   - Check `.gitignore_global` covers sensitive file patterns
   - Credential helpers that store plaintext
   - Hook scripts that execute without validation

5. **Audit tool configs** in `configs/tools/`:
   - Atuin: sync settings, encryption mode
   - gh: auth token storage method
   - Any tool config with inline credentials or tokens

6. **Audit file permissions** conceptually:
   - Flag configs that should be `chmod 600`
     (SSH, credentials)
   - Check if the install script sets appropriate permissions

7. **Check the install flow** (`install.sh`,
   `scripts/install/`):
   - Downloads over HTTP (not HTTPS)
   - Piping curl to shell without verification
   - Missing GPG/checksum verification for downloaded tools
   - Running commands as root unnecessarily

8. **Report findings** in severity tiers:
   - **Critical**: Exposed secrets, credentials in repo
   - **High**: Dangerous aliases, eval of remote code,
     weak SSH settings
   - **Medium**: Missing history protections,
     permissive file permissions
   - **Low**: Hardening suggestions, best practices
     not yet followed

   For each finding: file, line, description, and remediation.

## Important rules

- Never display actual secret values in output — redact them.
- Check that the protected fzf files don't contain hardcoded
  home paths (they should use `${HOME}`).
- This is an audit — suggest fixes but don't auto-apply
  without user confirmation.
- Focus on real risks over theoretical ones.
  Rank by actual exploitability.
