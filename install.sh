#!/usr/bin/env bash

set -Eeuo pipefail

# Define a function to handle errors
handle_error() {
  echo "Error on line $1: command exited with status $2"
  exit 1
}

# Install packages that are not already installed
install_packages() {
  # List of packages to install
  packages=(
    zsh
    tmux
  )

  # Install packages that are not already installed
  for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
      echo "Installing $package..."
      sudo apt-get update
      sudo apt-get install -y "$package"
    else
      echo "$package is already installed"
    fi
  done
}

# Set an error trap
trap 'handle_error $LINENO $?' ERR

# Run the installation function
install_packages

# Create symlinks for necessary files
symlink_files() {
  # Tmux
  rm -f ~/.tmux.conf
  ln -s ~/.dotfiles/dotfiles/tmux/tmux.conf ~/.tmux.conf
  echo "Linked .tmux.conf"
  # Zsh
  rm -f ~/.zshrc
  ln -s ~/.dotfiles/dotfiles/zsh/zshrc ~/.zshrc
  echo "Linked .zshrc"
  # Add more symlinks for other dotfiles as needed
}

# Run the symlink function
symlink_files
