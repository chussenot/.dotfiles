# Dotfiles Testing Sandbox

A Docker-based testing environment for your dotfiles that simulates a fresh Ubuntu 22.04 installation.

## Quick Start

1. **Setup the test environment:**

   ```bash
   ./test-sandbox/setup.sh
   ```

2. **Run automated tests:**

   ```bash
   ./test-sandbox/test.sh
   ```

3. **Start interactive testing:**

   ```bash
   ./test-sandbox/interactive.sh
   ```

4. **Clean up when done:**

   ```bash
   ./test-sandbox/cleanup.sh
   ```

## What This Does

### Setup (`setup.sh`)

- Creates a Docker container with Ubuntu 22.04
- Installs essential packages (curl, git, sudo, zsh, tmux, python3, vim)
- Creates a test user with sudo privileges
- Copies your dotfiles into the container
- Mounts your dotfiles directory as read-only

### Automated Test (`test.sh`)

- Runs your dotfiles installation script
- Tests basic functionality of installed tools
- Verifies that all components work correctly
- Provides feedback on success/failure

### Interactive Test (`interactive.sh`)

- Gives you an interactive shell in the test container
- Allows manual testing and debugging
- Perfect for troubleshooting issues
- Lets you test different scenarios

### Cleanup (`cleanup.sh`)

- Stops and removes the test container
- Cleans up any temporary files
- Frees up system resources

## Test Scenarios

### Fresh Installation Test

```bash
./test-sandbox/setup.sh
./test-sandbox/test.sh
```

This simulates installing your dotfiles on a completely fresh Ubuntu system.

### Interactive Development

```bash
./test-sandbox/setup.sh
./test-sandbox/interactive.sh
```

This gives you a shell where you can:

- Manually test your dotfiles
- Debug installation issues
- Test different configurations
- Experiment with changes

### Continuous Testing

```bash
# Setup once
./test-sandbox/setup.sh

# Test repeatedly
./test-sandbox/test.sh

# Clean up when done
./test-sandbox/cleanup.sh
```

## Customization

### Modify Test Environment

Edit `setup.sh` to:

- Change the Ubuntu version
- Add/remove packages
- Modify the test user setup
- Change container configuration

### Add Custom Tests

Edit `test.sh` to:

- Add more automated tests
- Test specific functionality
- Verify custom configurations
- Check for specific issues

### Custom Interactive Sessions

Edit `interactive.sh` to:

- Pre-configure the environment
- Set up specific test scenarios
- Add helper functions
- Customize the session

## Troubleshooting

### Container Issues

```bash
# Check container status
docker ps -a

# View container logs
docker logs dotfiles-test

# Restart container
docker restart dotfiles-test
```

### Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker permissions
sudo usermod -aG docker $USER
```

### Network Issues

```bash
# Check Docker network
docker network ls

# Restart Docker
sudo systemctl restart docker
```

## Best Practices

1. **Always test before deploying** - Use this sandbox before making changes to your main system
2. **Test different scenarios** - Try fresh installs, upgrades, and edge cases
3. **Document issues** - Keep notes of any problems you find
4. **Clean up regularly** - Use the cleanup script to avoid resource conflicts
5. **Version control** - Commit your test scripts to track changes

## Integration with CI/CD

You can integrate this testing setup with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Test Dotfiles
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Docker
        run: |
          sudo systemctl start docker
      - name: Run Tests
        run: |
          chmod +x test-sandbox/*.sh
          ./test-sandbox/setup.sh
          ./test-sandbox/test.sh
          ./test-sandbox/cleanup.sh
```

## Advanced Usage

### Multiple Test Environments

Create different test scenarios:

```bash
# Test with different Ubuntu versions
CONTAINER_NAME="dotfiles-test-20.04" DOCKER_IMAGE="ubuntu:20.04" ./test-sandbox/setup.sh

# Test with different user configurations
TEST_USER="developer" ./test-sandbox/setup.sh
```

### Automated Testing Pipeline

```bash
#!/bin/bash
# test-pipeline.sh

set -e

echo "🧪 Running dotfiles test pipeline..."

# Setup
./test-sandbox/setup.sh

# Run tests
./test-sandbox/test.sh

# Interactive testing (optional)
if [ "$1" = "--interactive" ]; then
    ./test-sandbox/interactive.sh
fi

# Cleanup
./test-sandbox/cleanup.sh

echo "✅ Test pipeline completed!"
```
