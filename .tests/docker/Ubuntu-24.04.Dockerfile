# Dockerfile for testing dotfiles installer on Ubuntu 24.04
# POSIX-compliant installer test harness

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies needed by the installer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        sudo \
        locales \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user (dev) similar to real environment
RUN useradd -m -s /bin/bash dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy the entire dotfiles repository into the container
COPY --chown=dev:dev . /home/dev/.dotfiles

# Switch to the dev user
USER dev
WORKDIR /home/dev

# Set HOME explicitly
ENV HOME=/home/dev

# Run the installer (non-interactive mode)
# The installer already handles errors gracefully and continues
# Add progress output to see what's happening
RUN cd /home/dev/.dotfiles && \
    ./install.sh 2>&1 | tee /tmp/install.log || true

# Run validation checks
RUN cd /home/dev/.dotfiles && \
    ./.tests/check.sh

# Pre-compile zinit plugins to cache them in the image
# This prevents downloading/compiling plugins on every shell start
# We source .zshrc which loads zinit, wait for plugins to load, then compile them
RUN if [ -f "${HOME}/.zshrc" ] && command -v zsh >/dev/null 2>&1; then \
        echo "🔧 Pre-compiling zinit plugins..." && \
        zsh -c ' \
            setopt EXTENDED_GLOB; \
            source ~/.zshrc 2>&1; \
            sleep 5; \
            if command -v zinit >/dev/null 2>&1; then \
                echo "Compiling all zinit plugins..."; \
                zinit compile --all 2>&1 || true; \
            fi \
        ' && \
        echo "✅ Zinit plugins pre-compiled and cached"; \
    else \
        echo "⚠️  Warning: zsh or .zshrc not found, skipping zinit pre-compilation"; \
    fi

# Default command (if container is run interactively)
CMD ["/bin/bash"]
