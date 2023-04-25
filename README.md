# dotfiles

This repository contains my personal configuration files for various tools and applications. Feel free to use any part of it that you find useful.

## Installation

1. Clone the repository to your home directory:

```
git clone https://github.com/chussenot/dotfiles.git ~/.dotfiles
```

2. Run the install script:

```
cd ~/.dotfiles && ./install.sh
```

This will create symbolic links from your home directory to the dotfiles in `~/.dotfiles`, and install any necessary dependencies.

3. Customize your local settings or overrides in `~/.vim/vimrc.local`.

4. Enjoy!

## What's included?

- Neovim configuration with plugins managed by [vim-plug](https://github.com/junegunn/vim-plug)
- Zsh configuration with [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- Tmux configuration with [tpm](https://github.com/tmux-plugins/tpm)
- Various other configuration files for tools like Git, Ripgrep, and fd

## Notes

### Tmux Configuration

My Tmux configuration makes the following changes:

- The prefix key is changed from `C-b` to `C-a`
- The status bar is configured with a date and time display, and the window and pane numbers are highlighted
- The status bar refreshes every 5 seconds
- The `|` key maximizes a pane
- The arrow keys are used to switch panes, and the `Alt` key can be held to switch between panes without the prefix key
- The base index for windows and panes is set to 1 instead of 0
- Tmux is configured to automatically start with the last session

### Zsh Configuration

My Zsh configuration uses the [ys theme](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#ys) from Oh My Zsh, and includes a number of aliases and environment variables for tools like Ruby and AWS. The [z](https://github.com/rupa/z) tool is also included for directory jumping.

### Neovim Configuration

My Neovim configuration uses [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins, and includes settings for a number of languages, including Ruby, Python, and Rust. Various plugins are included to provide functionality like autocompletion, fuzzy finding, and linting.

