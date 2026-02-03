# Multi-Platform Support

This dotfiles repository now supports multiple platforms with a POSIX-compliant
installation system.

## Supported Platforms

### Fully Supported

- **Linux (Ubuntu/Debian)**: Full package installation support via `apt-get`
- **macOS**: Full package installation support via Homebrew

### Partially Supported

- **Arch Linux**: Package installation support via `pacman` (stubbed)
- **Fedora**: Package installation support via `dnf` (stubbed)
- **Alpine Linux**: Package installation support via `apk` (stubbed)

### Architecture Support

- **amd64/x86_64**: Fully supported
- **arm64/aarch64**: Supported (package names may vary)
- **arm**: Supported (package names may vary)

## Platform Detection

The platform detection system automatically identifies:

- **Operating System**: Linux, macOS, FreeBSD, OpenBSD, or unknown
- **Distribution**: Ubuntu, Debian, Arch, Fedora, Alpine, macOS, or unknown
- **Architecture**: amd64, arm64, arm, or unknown

### Detection Methods

- **OS**: Uses `uname -s`
- **Architecture**: Uses `uname -m`
- **Distribution**: Parses `/etc/os-release` on Linux systems

## Usage

### Main Installer

The main installer (`install.sh`) automatically detects your platform and uses
the appropriate package manager:

```sh
./install.sh
```

### Platform Detection Module

The platform detection module (`scripts/utils/platform.sh`) provides:

- `platform_detect`: Detects and sets platform variables
- `is_linux()`, `is_macos()`, etc.: Platform predicate functions
- `install_pkg package1 package2 ...`: Generic package installer
- `pkg_installed package`: Check if package is installed
- `pkg_available package`: Check if package is available

### Debug Script

Test platform detection:

```sh
./scripts/utils/debug_platform.sh
```

This script will:

- Display detected platform information
- Test all platform predicates
- Check package manager availability
- Show what commands would be run (dry-run)

## Adding Support for New Platforms

### 1. Update Platform Detection

Edit `scripts/utils/platform.sh`:

- Add OS detection in `platform_detect()` if needed
- Add distribution detection in `platform_detect()` for Linux distros
- Add architecture detection if needed

### 2. Add Package Manager Support

Edit `scripts/utils/platform.sh`:

- Add platform check in `install_pkg()`
- Add package manager command (e.g., `yum`, `zypper`, etc.)
- Add support in `pkg_installed()` and `pkg_available()`

### 3. Add Platform-Specific Setup

Edit `scripts/utils/platform_setup.sh`:

- Add `setup_<distro>()` function
- Add platform-specific configuration logic
- Update `platform_setup()` dispatcher

### 4. Update Package Lists

Edit `scripts/install/install-packages.sh`:

- Add platform-specific package list
- Map package names to platform equivalents
- Handle platform-specific package availability

## POSIX Compliance

All scripts are strictly POSIX-compliant:

- Use `#!/bin/sh` (not bash)
- No bashisms (`[[ ]]`, arrays, `(( ))`, etc.)
- Use `$(command)` instead of backticks
- Use `printf` instead of `echo -e`
- Proper variable quoting: `"${var}"`
- All scripts pass `shellcheck --shell=sh`

## Platform-Specific Notes

### Ubuntu/Debian

- Uses `apt-get` for package management
- Uses `dpkg` for package status checks
- Uses `apt-cache` for package availability checks

### macOS

- Requires Homebrew (`brew`) to be installed
- Uses Homebrew for package management
- Package names may differ from Linux (e.g., `python@3` vs `python3`)

### Arch Linux

- Uses `pacman` for package management
- Package names may differ from Ubuntu/Debian
- AUR packages require manual installation

### Fedora

- Uses `dnf` for package management
- Package names may differ from Ubuntu/Debian

### Alpine

- Uses `apk` for package management
- Minimal package set available
- Package names may differ significantly

## Testing

### Test Platform Detection

```sh
./scripts/utils/debug_platform.sh
```

### Test Package Installation (Dry-Run)

The debug script shows what commands would be executed without actually
installing packages.

### Test Full Installation

```sh
./install.sh
```

## Safety Features

The installation system includes several safety mechanisms:

### Automatic Backups

Before modifying any files, the installer creates a timestamped backup:

```sh
~/.dotfiles_backup/YYYYMMDD_HHMMSS/
```

Files backed up include:

- `~/.zshrc`
- `~/.tmux.conf`
- `~/.inputrc`
- `~/.config/nvim`
- `~/.config/bat`
- `~/.tool-versions`

### Non-Destructive Operations

- Existing files are moved to `.backup` suffix before replacement
- Symlinks are removed and recreated (safe operation)
- The installer refuses to run as root user
- All operations are logged with clear status messages

### Error Handling

The installer uses defensive programming:

```sh
set -eu  # Exit on error, undefined variable
```

- Non-critical failures continue with warnings
- Critical failures exit immediately with error messages
- Network operations check connectivity before proceeding

### Dry-Run Testing

Test platform detection without making changes:

```sh
./scripts/utils/debug_platform.sh
```

## Troubleshooting

For comprehensive troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

### Quick Diagnostics

```sh
# Check platform detection
./scripts/utils/debug_platform.sh

# Check POSIX compliance
./scripts/utils/posix_check.sh

# Verbose installation
sh -x ./install.sh 2>&1 | tee install.log
```

### Unknown Platform

If platform detection returns "unknown":

1. Check system identification:

   ```sh
   uname -s          # Operating system
   uname -m          # Architecture
   cat /etc/os-release  # Distribution info (Linux)
   ```

2. Add support in `scripts/utils/platform.sh` if needed (see "Adding Support for New Platforms")

### Package Installation Fails

1. **Update package lists**:

   ```sh
   # Ubuntu/Debian
   sudo apt-get update

   # macOS
   brew update
   ```

2. **Check package names** - they differ between platforms:

   ```sh
   # Search for package
   apt-cache search <term>  # Ubuntu/Debian
   brew search <term>       # macOS
   ```

3. **Verify sudo access**:

   ```sh
   sudo -v
   ```

4. **Install packages manually** if automated installation fails:

   ```sh
   sudo apt-get install zsh tmux git curl  # Ubuntu/Debian
   brew install zsh tmux git curl          # macOS
   ```

### Platform Not Supported

If your platform is not in the supported list:

1. **Check for similar platforms** - Debian-based distros often work like Ubuntu
2. **Manually install required packages** - See package list in `scripts/install/install-packages.sh`
3. **Skip package installation** - The installer will continue with warnings
4. **Contribute support** - Add your platform to `scripts/utils/platform.sh`

## Files

| File                                  | Purpose                                   |
| ------------------------------------- | ----------------------------------------- |
| `install.sh`                          | Main installer (entry point)              |
| `scripts/utils/platform.sh`           | Platform detection and package management |
| `scripts/utils/platform_setup.sh`     | Platform-specific setup functions         |
| `scripts/utils/debug_platform.sh`     | Platform detection debug/test script      |
| `scripts/utils/backup.sh`             | Backup existing dotfiles                  |
| `scripts/install/install-packages.sh` | Multi-platform package installer          |
| `scripts/setup/setup-symlinks.sh`     | Create symlinks for config files          |

## Related Documentation

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [POSIX_COMPLIANCE.md](POSIX_COMPLIANCE.md) - Shell script standards
