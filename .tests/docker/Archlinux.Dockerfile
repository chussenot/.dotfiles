# Dockerfile for testing dotfiles installer on Arch Linux
# POSIX-compliant installer test harness

FROM archlinux:latest

# Install minimal bootstrap dependencies for the container-friendly profile
RUN pacman -Sy --noconfirm --needed \
        ca-certificates \
        git \
        curl \
        zsh && \
    yes | pacman -Scc

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

# Use the container-friendly install profile in Docker CI
ENV DOTFILES_TEST_PROFILE=minimal

# Run the installer
RUN cd /home/dev/.dotfiles && \
    ./install.sh --minimal 2>&1 | tee /tmp/install.log || true

# Run validation checks
RUN cd /home/dev/.dotfiles && \
    ./.tests/check.sh

# Default command (if container is run interactively)
CMD ["/bin/sh"]
