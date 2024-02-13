# Dotfiles

This repository contains my personal configuration files for various tools and applications.
Feel free to use any part of it that you find useful.

I'm using the `zsh` shell for my day-to-day work...

## Disclaimer: Ubuntu-Specific Configuration

Please be aware that this configuration has been rigorously tested and is primarily intended for use with Ubuntu.
Specifically, it has been verified on an Ubuntu system running Linux kernel version 6.5.0-17-generic, with gcc version 12.3.0 and GNU ld version 2.38, as part of the Ubuntu 22.04 LTS distribution. While this setup may be compatible with other Linux distributions or versions, optimal performance and compatibility can only be guaranteed for the tested Ubuntu environment detailed above.

Users attempting to implement this configuration on other systems should proceed with caution and may need to make adjustments to ensure compatibility.

Your feedback and contributions to enhance cross-distribution compatibility are welcome, but support cannot be guaranteed for environments other than the specified Ubuntu setup.

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

- Tmux integration and configuration with [tpm](https://github.com/tmux-plugins/tpm)
- Neovim configuration with plugins managed by [vim-plug](https://github.com/junegunn/vim-plug)
- Zsh configuration with [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- Various other configuration files for tools like Git, Ripgrep, and fd

But also...

- Oh-My-Zsh: A community-driven framework for managing Zsh configuration, including themes, plugins, and settings.
- Zinit: A flexible and fast Zsh plugin manager.
- ASDF: A version manager that handles multiple runtime versions, such as Node.js, Python, Ruby, and more.
- FZF: A fuzzy finder that helps you quickly search and select files, directories, and other items from the command line.
- Ag: The Silver Searcher, a fast code searching tool.
- Direnv: An environment switcher for the shell.
- Tmuxinator: A tool for managing complex Tmux sessions through YAML configuration files.
- Docker: A platform for developing, shipping, and running applications inside containers.
- Docker Compose: A tool for defining and running multi-container Docker applications.
- Kubectl: The command-line tool for interacting with Kubernetes clusters.
- Helm: A package manager for Kubernetes that simplifies the deployment and management of applications.
- Gcloud: The command-line interface for Google Cloud Platform.
- Volta: A tool for managing JavaScript command-line tools.

And few languages...

- Python: A popular programming language.
- Ruby: Another popular programming language.
- Go (Golang): A programming language developed by Google.
- Rust: A systems programming language that focuses on performance and safety.
- Java: A widely used programming language for building cross-platform applications.
- Node.js: A JavaScript runtime that allows you to execute JavaScript code outside a web browser.

## Notes

### Tmux Configuration

Tmux is a terminal multiplexer that allows you to run multiple terminal sessions within a single window.
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

