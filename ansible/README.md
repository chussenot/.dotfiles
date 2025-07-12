# Dotfiles Testing Environment

This directory contains Ansible playbooks and scripts to create a testing sandbox for your dotfiles using Docker containers.

## Prerequisites

1. **Docker** installed and running
2. **Ansible** installed
3. **Ansible collections** installed

## Setup

1. Install Ansible collections:

   ```bash
   ansible-galaxy collection install community.docker
   ```

2. Run the setup playbook:

   ```bash
   ansible-playbook playbook.yml
   ```

## Usage

### Automated Test

Run the automated test to install your dotfiles:

```bash
./test_dotfiles.sh
```

### Interactive Test

Start an interactive session in the test container:

```bash
./interactive_test.sh
```

### Cleanup

Clean up the test environment:

```bash
./cleanup.sh
```

## What the Setup Does

1. **Creates a Docker container** with Ubuntu 22.04
2. **Installs basic packages** (curl, git, sudo, zsh, tmux, python3, vim)
3. **Creates a test user** with sudo privileges
4. **Copies your dotfiles** into the container
5. **Provides test scripts** for automated and interactive testing

## Test Scenarios

### Fresh Installation Test

```bash
./test_dotfiles.sh
```

This will:

- Install your dotfiles in a fresh Ubuntu environment
- Test the installation process
- Verify that all components work correctly

### Interactive Development Test

```bash
./interactive_test.sh
```

This will:

- Give you an interactive shell in the test container
- Allow you to manually test your dotfiles
- Let you debug any issues

### Custom Test Scenarios

You can create custom test scenarios by modifying the test scripts or adding new ones.

## Troubleshooting

### Container Issues

If the container fails to start:

```bash
docker ps -a  # Check container status
docker logs dotfiles-test  # Check container logs
./cleanup.sh  # Clean up and try again
```

### Permission Issues

If you encounter permission issues:

```bash
sudo chown -R $USER:$USER .
```

### Ansible Issues

If Ansible fails:

```bash
ansible-playbook playbook.yml --verbose
```

## Customization

You can customize the testing environment by modifying:

- `playbook.yml`: Change Docker image, container name, or packages
- `test_dotfiles.sh`: Modify the test process
- `interactive_test.sh`: Change the interactive session behavior

## Best Practices

1. **Always test in the sandbox** before deploying to production
2. **Use the cleanup script** to avoid resource conflicts
3. **Test different scenarios** (fresh install, upgrade, etc.)
4. **Document any issues** you find during testing
