# Docker Test Harness

This directory contains a Docker-based test harness for validating the dotfiles installer in a clean, reproducible environment.

## Quick Start

Run all tests:

```sh
./.tests/run-all.sh
```

## What It Does

1. **Builds Docker images** for each platform (currently Ubuntu 24.04)
2. **Runs the installer** inside a clean container
3. **Validates the installation** by checking:
   - Expected files and directories exist
   - Symlinks are correct
   - Essential commands are available
   - Antidote plugin manager is installed

## Troubleshooting

### Build is Slow or Hanging

The package installation step can take 5-10 minutes as it installs many packages. This is
normal. You can monitor progress by:

1. **Check Docker build logs** (in another terminal):

   ```sh
   docker ps
   docker logs <container-id>
   ```

2. **Cancel and restart** if needed:
   - Press `Ctrl+C` to cancel
   - The optimized installer batches packages for faster installation

### Build Fails

If the build fails:

1. Check the error message in the output
2. Verify Docker is running: `docker info`
3. Check disk space: `df -h`
4. Try cleaning up: `docker system prune -a`

### Validation Failures

If validation checks fail:

1. The error message will show which check failed
2. Common issues:
   - Missing packages (check package installation step)
   - Symlink issues (check setup-symlinks.sh)
   - Missing tools (check if installer completed successfully)

## Files

- `run-all.sh` - Main test runner script
- `check.sh` - Validation script (runs inside container)
- `docker/Ubuntu-24.04.Dockerfile` - Ubuntu 24.04 test image

## CI Integration

See comments in `run-all.sh` for examples of how to integrate into:

- GitHub Actions
- GitLab CI
- CircleCI
