#!/usr/bin/env bash

# bootstrap installs things.

echo "                                                      "
echo "                __      __  _____ __                  "
echo "           ____/ /___  / /_/ __(_) /__  _____         "
echo "          / __  / __ \/ __/ /_/ / / _ \/ ___/         "
echo "         / /_/ / /_/ / /_/ __/ / /  __(__  )          "
echo "         \__,_/\____/\__/_/ /_/_/\___/____/           "

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
    cmake
    python3-pip
    neovim
  )

  # Check which package provides the 'ctags' virtual package and install it
  if apt-cache show exuberant-ctags >/dev/null 2>&1; then
    packages+=(exuberant-ctags)
  elif apt-cache show universal-ctags >/dev/null 2>&1; then
    packages+=(universal-ctags)
  else
    echo "Neither exuberant-ctags nor universal-ctags are available in the package repositories"
    exit 1
  fi

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

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

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

  # NeoVim
  rm -Rf ~/.config/nvim
  ln -s ~/.dotfiles/dotfiles/nvim ~/.config
  echo "Linked init.vim"

}

# Run the symlink function
symlink_files

# Link nvim config to ~/.vim
if [ ! -d ~/.vim ]; then
    ln -s ~/.config/nvim ~/.vim
fi

# Bootstrap vim config
cd ~/.vim
make

# Install neovim plugins
echo "Installing neovim plugins..."
nvim +PlugInstall +qall

echo "Installation completed successfully!"
