# My vim config


My little own vim configuration. Use and fork as you see fit.


## Dependencies

  * for [YouCompleteMe](http://valloric.github.io/YouCompleteMe/)
    * `cmake`
    * `ctags`
    * if using [neovim](https://github.com/neovim/neovim/) ([installation instructions here](https://github.com/neovim/neovim/wiki/Installing-Neovim)), you'd better install the Python neovim module (`pip install neovim`). And if you use pyenv, you'd better add `export
      PYTHON_CONFIGURE_OPTS="--enable-shared"` in your `.bashrc|.zshrc|.profile|…` before installing your global Python version.

## Usage

  * git clone the project: `git clone https://github.com/changa/vimconfig ~/.vim`
  * boostrap: `cd ~/.vim && make`
  * add your local settings or overrides in `~/.vim/vimrc.local`
  * Profit!


## Plugins (handled by [vim-plug](https://github.com/junegunn/vim-plug))

 * [BufOnly.vim](https://github.com/vim-scripts/BufOnly.vim)
 * [SyntaxComplete](https://github.com/vim-scripts/SyntaxComplete)
 * [ack.vim](https://github.com/vim-scripts/ack.vim)
 * [alchemist.vim](https://github.com/slashmili/alchemist.vim)
 * [darkspectrum](https://github.com/vim-scripts/darkspectrum)
 * [ditaa](https://github.com/vim-scripts/ditaa)
 * [easybuffer.vim](https://github.com/vim-scripts/easybuffer.vim)
 * [file-line](https://github.com/bogado/file-line)
 * [fzf.vim](https://github.com/junegunn/fzf.vim)
 * [fzf](https://github.com/junegunn/fzf)
 * [gruvbox](https://github.com/morhetz/gruvbox)
 * [harlequin](https://github.com/nielsmadan/harlequin)
 * [jellybeans.vim](https://github.com/nanotech/jellybeans.vim)
 * [molokai](https://github.com/vim-scripts/molokai)
 * [monokai](https://github.com/lsdr/monokai)
 * [neodark.vim](https://github.com/KeitaNakamura/neodark.vim)
 * [neomake](https://github.com/neomake/neomake)
 * [neovim-colors-solarized-truecolor-only](https://github.com/frankier/neovim-colors-solarized-truecolor-only)
 * [nerdtree](https://github.com/scrooloose/nerdtree)
 * [phoenix.vim](https://github.com/c-brenn/phoenix.vim)
 * [rainbow](https://github.com/luochen1990/rainbow)
 * [supertab](https://github.com/ervandew/supertab)
 * [surround.vim](https://github.com/vim-scripts/surround.vim)
 * [syntastic](https://github.com/scrooloose/syntastic)
 * [tComment](https://github.com/vim-scripts/tComment)
 * [tabular](https://github.com/godlygeek/tabular)
 * [undotree](https://github.com/mbbill/undotree)
 * [vim-airline](https://github.com/vim-airline/vim-airline)
 * [vim-autoformat](https://github.com/Chiel92/vim-autoformat)
 * [vim-brogrammer-theme](https://github.com/marciomazza/vim-brogrammer-theme)
 * [vim-bundler](https://github.com/tpope/vim-bundler)
 * [vim-characterize](https://github.com/tpope/vim-characterize)
 * [vim-closetag](https://github.com/alvan/vim-closetag)
 * [vim-css-color](https://github.com/ap/vim-css-color)
 * [vim-css3-syntax](https://github.com/hail2u/vim-css3-syntax)
 * [vim-desert-warm-256](https://github.com/rainux/vim-desert-warm-256)
 * [vim-desert256](https://github.com/brafales/vim-desert256)
 * [vim-easymotion](https://github.com/Lokaltog/vim-easymotion)
 * [vim-endwise](https://github.com/longthanhtran/vim-endwise)
 * [vim-evolution](https://github.com/petelewis/vim-evolution)
 * [vim-fontsize](https://github.com/drmikehenry/vim-fontsize)
 * [vim-fugitive](https://github.com/tpope/vim-fugitive)
 * [vim-gfm-syntax](https://github.com/rhysd/vim-gfm-syntax)
 * [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
 * [vim-grex](https://github.com/kana/vim-grex)
 * [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)
 * [vim-hcl](https://github.com/b4b4r07/vim-hcl)
 * [vim-hclfmt](https://github.com/fatih/vim-hclfmt)
 * [vim-luna](https://github.com/notpratheek/vim-luna)
 * [vim-metarw-git](https://github.com/kana/vim-metarw-git)
 * [vim-obsession](https://github.com/tpope/vim-obsession)
 * [vim-obsidian](https://github.com/trevorrjohn/vim-obsidian)
 * [vim-plugin-AnsiEsc](https://github.com/powerman/vim-plugin-AnsiEsc)
 * [vim-polyglot](https://github.com/sheerun/vim-polyglot)
 * [vim-projectionist](https://github.com/tpope/vim-projectionist)
 * [vim-rails](https://github.com/tpope/vim-rails)
 * [vim-rake](https://github.com/tpope/vim-rake)
 * [vim-rbenv](https://github.com/tpope/vim-rbenv)
 * [vim-repeat](https://github.com/kana/vim-repeat)
 * [vim-sensible](https://github.com/tpope/vim-sensible)
 * [vim-signature](https://github.com/kshenoy/vim-signature)
 * [vim-smartinput](https://github.com/kana/vim-smartinput)
 * [vim-textobj-indent](https://github.com/kana/vim-textobj-indent)
 * [vim-textobj-line](https://github.com/kana/vim-textobj-line)
 * [vim-textobj-rubyblock](https://github.com/nelstrom/vim-textobj-rubyblock)
 * [vim-textobj-user](https://github.com/kana/vim-textobj-user)
 * [vim-tomorrow-theme](https://github.com/chriskempson/vim-tomorrow-theme)
 * [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
 * [vim-visual-star-search](https://github.com/nelstrom/vim-visual-star-search)
 * [vim-vividchalk](https://github.com/tpope/vim-vividchalk)
 * [vimproc.vim](https://github.com/Shougo/vimproc.vim)
 * [vimroom](https://github.com/mikewest/vimroom)
