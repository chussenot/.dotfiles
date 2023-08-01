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

# Versions
ASDF_VERSION=v0.12.0

# Install packages that are not already installed
install_packages() {
  # List of packages to install
  packages=(
    zsh
    tmux
    python3-pip
    jq
    nasm
    gcc
    gcc-multilib
    libc6-dev
    cmake
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
  rm -f "$HOME/.tmux.conf"
  ln -s ~/.dotfiles/dotfiles/tmux/tmux.conf ~/.tmux.conf
  echo "Linked .tmux.conf"

  # Zsh
  rm -f "$HOME/.zshrc"
  ln -s ~/.dotfiles/dotfiles/zsh/zshrc ~/.zshrc
  echo "Linked .zshrc"

  # NeoVim
  rm -Rf "$HOME/.config/nvim"
  ln -s ~/.dotfiles/dotfiles/nvim ~/.config
  echo "Linked init.vim"

  # asdf
  rm -f "$HOME/.tool-versions"
  ln -s ~/.dotfiles/dotfiles/asdf/tool-versions ~/.tool-versions
  echo "Linked asdf tool versions"
}

# Run the symlink function
symlink_files

# Link nvim config to ~/.vim
if [ ! -d ~/.vim ]; then
    ln -s ~/.config/nvim ~/.vim
fi

# Bootstrap vim config
cd ~/.vim
# make

# Install neovim plugins
echo "Installing neovim plugins..."
# nvim +PlugInstall +qall
echo "Installation completed successfully!"


# Install asdf
echo "Installing asdf..."
# Define the destination folder for cloning
dest_folder="$HOME/.asdf"

# Function to handle errors
handle_error() {
  local line_number="$1"
  local exit_code="$2"
  echo "Error on line $line_number: command exited with status $exit_code"
}

# Set an error trap
trap 'handle_error $LINENO $?' ERR

# Check if the folder exists
if [ -d "$dest_folder" ]; then
    # If the folder exists, go to the repository directory
    cd "$dest_folder"
    # Update the repository to the latest changes
    git pull origin master
    # Checkout the desired version
    git checkout $ASDF_VERSION
    echo "Updated and checked out version $ASDF_VERSION in $dest_folder"
else
    # If the folder does not exist, perform the git clone command
    git clone https://github.com/asdf-vm/asdf.git "$dest_folder"
     / --branch $ASDF_VERSION
    echo "Cloned version $ASDF_VERSION in $dest_folder"
fi

# Source and refresh
source "$HOME/.asdf/asdf.sh"
asdf plugin update --all

# Function to add an asdf plugin if it is not already added
add_asdf_plugin() {
  plugin_name="$1"
  plugin_url="$2"

  if ! asdf plugin list | grep -q "$plugin_name"; then
    asdf plugin add "$plugin_name" "$plugin_url"
  else
    echo "Plugin named $plugin_name already added"
  fi
}

# Function to install a tool using asdf
install_tool() {
  tool_name="$1"
  tool_version="$2"
  asdf install "$tool_name" "$tool_version"
}

plugins=(
  "neovim https://github.com/richin13/asdf-neovim"
  "tfstate-lookup https://github.com/carnei-ro/asdf-tfstate-lookup.git"
  "bat https://gitlab.com/wt0f/asdf-bat"
  "golang https://github.com/asdf-community/asdf-golang.git"
  "ctop https://github.com/NeoHsu/asdf-ctop.git"
  "terraformer https://github.com/grimoh/asdf-terraformer.git"
  "rust https://github.com/asdf-community/asdf-rust.git"
  "crystal https://github.com/asdf-community/asdf-crystal.git"
  "k9s https://github.com/looztra/asdf-k9s"
  "kubectl https://github.com/asdf-community/asdf-kubectl.git"
  "ctop https://github.com/NeoHsu/asdf-ctop.git"
  "gcloud https://github.com/jthegedus/asdf-gcloud"

)

# Iterate over the array and install the plugins
for plugin_info in "${plugins[@]}"; do
  plugin_name="${plugin_info%% *}"      # Extract the plugin name
  plugin_url="${plugin_info#* }"       # Extract the plugin URL

  add_asdf_plugin "$plugin_name" "$plugin_url"
done

# Read the .tool-versions file line by line
while read -r tool_info; do
  # Extract the tool name and version from the line
  tool_name="${tool_info%% *}"
  tool_version="${tool_info#* }"

  # Install the tool with asdf
  install_tool "$tool_name" "$tool_version"
done < "$HOME/.tool-versions"
