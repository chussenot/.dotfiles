# Dockerfile for testing dotfiles installer on Fedora 41
# POSIX-compliant installer test harness

FROM fedora:41

# Install minimal dependencies needed by the installer
RUN dnf install -y \
        git \
        curl \
        sudo \
        zsh \
        glibc-langpack-en && \
    dnf clean all

# Set up locale
ENV LANG=en_US.UTF-8
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

# Skip heavy mise conf.d tools in CI (cargo, pipx, go packages)
ENV MISE_IGNORED_CONFIG_PATHS=/home/dev/.config/mise/conf.d

# Run the installer
RUN cd /home/dev/.dotfiles && \
    ./install.sh 2>&1 | tee /tmp/install.log || true

# Run validation checks
RUN cd /home/dev/.dotfiles && \
    ./.tests/check.sh

# Default command (if container is run interactively)
CMD ["/bin/bash"]
