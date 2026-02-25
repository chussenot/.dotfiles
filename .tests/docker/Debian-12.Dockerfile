# Dockerfile for testing dotfiles installer on Debian 12 (Bookworm)
# POSIX-compliant installer test harness

FROM debian:12

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies needed by the installer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        sudo \
        zsh \
        locales \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
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
