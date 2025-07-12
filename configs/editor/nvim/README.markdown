# My vim config

My little own vim configuration. Use and fork as you see fit.
This <3 [config](https://github.com/changa/vimconfig) his based on the work of my friend Changa



## Dependencies

  * for [YouCompleteMe](http://valloric.github.io/YouCompleteMe/)
    * `cmake`
    * `ctags`
    * if using [neovim](https://github.com/neovim/neovim/) ([installation instructions here](https://github.com/neovim/neovim/wiki/Installing-Neovim)), you'd better install the Python neovim module (`pip install neovim`). And if you use pyenv, you'd better add `export
      PYTHON_CONFIGURE_OPTS="--enable-shared"` in your `.bashrc|.zshrc|.profile|…` before installing your global Python version.

## Usage

  * boostrap: `cd ~/.config/nvim && make`
  * add your local settings or overrides in `~/.vim/vimrc.local`
  * Profit!

## Plugins (handled by [vim-plug](https://github.com/junegunn/vim-plug))
