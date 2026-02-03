" vim: set ft=vim foldmethod=marker foldenable :

call plug#begin()

"  BASICS

"  vim-sensible " sensible set of defaults
"
" Think of sensible.vim as one step above 'nocompatible' mode: a universal set of
" defaults that (hopefully) everyone can agree on.
"
" * If you're new to Vim, you can install this as a starting point, rather than
"   copying some random vimrc you found.
"
" * If you're pair programming and you can't agree on whose vimrc to use, this
"   can be your neutral territory.
"
" * If you're administrating a server with an account that's not exclusive
"   yours, you can scp this up to make things a bit more tolerable.
"
" * If you're troubleshooting a plugin and need to rule out interference from
"   your vimrc, having this installed will ensure you still have some basic
"   amenities.
"
" https://github.com/tpope/vim-sensible

if has("nvim")
  " Prevent sensible from being loaded with neovim
  let g:loaded_sensible = 1
endif
" SECURITY: Pin plugin versions to prevent supply chain attacks
Plug 'tpope/vim-sensible', { 'tag': 'v2.0' }
"

"  vim-surround
"
" Surround.vim is all about "surroundings": parentheses, brackets, quotes, XML
" tags, and more. The plugin provides mappings to easily delete, change and add
" such surroundings in pairs.
"
" https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround', { 'tag': 'v2.2' }
"

"  vim-repeat
"
" If you've ever tried using the . command after a plugin map, you were likely
" disappointed to discover it only repeated the last native command inside that
" map, rather than the map as a whole. That disappointment ends today. Repeat.vim
" remaps . in a way that plugins can tap into it.
"
" http://www.vim.org/scripts/script.php?script_id=2136
" https://github.com/kana/vim-repeat
Plug 'kana/vim-repeat'
"

"  undotree
" Display your undo history in a graph
Plug 'mbbill/undotree'
"


"  fontsize
" convenient mappings for changing the font size in Gvim
Plug 'drmikehenry/vim-fontsize'


"  /BASICS


"  BUFFERS

"  easybuffer.vim
"
" a simple plugin to quickly switch between buffers using corresponding keys or
" buffer numbers displayed in easybuffer quick switch window
Plug 'vim-scripts/easybuffer.vim'
"

" A tree explorer plugin for vim.
Plug 'scrooloose/nerdtree', { 'tag': '7.1.2' }
" Defines commands that will work on files inside a Visual selection
Plug 'PhilRunninger/nerdtree-visual-selection'

" Close all buffers but current one
Plug 'vim-scripts/BufOnly.vim'
"


"  LANGUAGES & SYNTAXES

" vim-ruby
"
" see https://github.com/vim-ruby/vim-ruby
Plug 'vim-ruby/vim-ruby'
"
"  vim-ployglot
" A collection of language packs for Vim.
" see https://github.com/sheerun/vim-polyglot
Plug 'sheerun/vim-polyglot', { 'tag': 'v4.17.0' }


" match-up is a plugin that lets you highlight, navigate, and operate on sets
" of matching text. It extends vim's % key to language-specific words instead
" of just single characters.
" https://github.com/andymass/vim-matchup
Plug 'andymass/vim-matchup'

" nwim-treesitter
" https://github.com/nvim-treesitter/nvim-treesitter
if has("nvim")
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate', 'tag': 'v0.9.2' }
  Plug 'RRethy/nvim-treesitter-endwise'
  " nvim-ts-rainbow is deprecated, replaced with rainbow-delimiters.nvim
  Plug 'HiPhish/rainbow-delimiters.nvim'
  Plug 'windwp/nvim-ts-autotag'

  " Neovim treesitter plugin for setting the commentstring based on the cursor
  " location in a file.
  " see https://github.com/JoosepAlviste/nvim-ts-context-commentstring
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'
endif

"  RUBY-RELATED (lazy-loaded for Ruby files)

"  vim-endwise
" endwise.vim: wisely add "end" in ruby, endfunction/endif/more in vim script, etc
Plug 'longthanhtran/vim-endwise'

"  vim-rails (lazy load for rails projects)
Plug 'tpope/vim-rails', { 'for': ['ruby', 'eruby', 'haml', 'slim'] }

" vim-ragtag (lazy load for markup files)
Plug 'tpope/vim-ragtag', { 'for': ['html', 'xml', 'eruby', 'php', 'jsp'] }

"  rake-vim (lazy load)
Plug 'tpope/vim-rake', { 'for': 'ruby' }

"  vim-bundler (lazy load)
Plug 'tpope/vim-bundler', { 'for': 'ruby' }

"  vim-rbenv (lazy load)
Plug 'tpope/vim-rbenv', { 'for': 'ruby' }

"  /RUBY-RELATED

"  Phoenix (lazy load for Elixir)
Plug 'tpope/vim-projectionist'
Plug 'c-brenn/phoenix.vim', { 'for': 'elixir' }

" css3 (lazy load)
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss', 'sass'] }

" markdown (lazy load)
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Elixir (lazy load)
Plug 'slashmili/alchemist.vim', { 'for': 'elixir' }
Plug 'powerman/vim-plugin-AnsiEsc', { 'for': 'elixir' }

" Lisps
Plug 'luochen1990/rainbow'

" ditaa (lazy load)
Plug 'vim-scripts/ditaa', { 'for': 'ditaa' }

" jinja/liquid/nunjucks (lazy load)
Plug 'lepture/vim-jinja', { 'for': ['jinja', 'jinja2', 'htmljinja'] }

"  /LANGUAGES


"  GIT

"  vim-fugitive
"
" fugitive.vim: a Git wrapper so awesome, it should be illegal
" http://www.vim.org/scripts/script.php?script_id=2975
" https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive', { 'tag': 'v3.7' }

" A git commit browser.
" https://github.com/junegunn/gv.vim
Plug 'junegunn/gv.vim'

" GitHub extension for fugitive.vim
" https://github.com/tpope/vim-rhubarb
Plug 'tpope/vim-rhubarb'


" Vim and Neovim plugin to reveal the commit messages under the cursor
" https://github.com/rhysd/git-messenger.vim
Plug 'rhysd/git-messenger.vim'

"  vim-metarw-git

" *metarw-git* is a scheme for |metarw| to read or to browse various objects in
" a git repository with fakepaths like "git:HEAD~3:src/ui.c".
Plug 'kana/vim-metarw-git'
"

"  vim-gitgutter
" shows a git diff in the 'gutter' (sign column). It shows whether each line
" has been added, modified, and where lines have been removed.
Plug 'airblade/vim-gitgutter'
"


"  /GIT


"  COMPLETION

Plug 'vim-scripts/SyntaxComplete'

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
let g:LanguageClient_autoStop = 0
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['tcp://localhost:7658']
    \ }

if ! has('nvim')
else
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'Shougo/neco-syntax'
"

" ddc
" https://github.com/Shougo/ddc.vim

Plug 'Shougo/ddc.vim'
let g:denops_disable_version_check = 1
Plug 'vim-denops/denops.vim', { 'branch': 'main'}

" Install your sources
Plug 'Shougo/ddc-around', { 'branch': 'main'}

" Install your filters
Plug 'Shougo/ddc-matcher_head', { 'branch': 'main'}
Plug 'Shougo/ddc-sorter_rank', { 'branch': 'main'}

Plug 'Shougo/pum.vim'
Plug 'tani/ddc-fuzzy'

"  SNIPPETS
" The Neosnippet plug-In adds snippet support to Vim
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
let g:neosnippet#snippets_directory='~/.vim/snippets'
"

" }}}


"  TEXT OBJECTS

"  textobj-entire
" Text objects for entire buffer
" https://github.com/kana/vim-textobj-entire
" (relies on https://github.com/kana/vim-textobj-user)
Plug 'kana/vim-textobj-user' | Plug 'kana/vim-textobj-entire'
"

" Vim plugin to provide text objects to select a portion of the current line
Plug 'kana/vim-textobj-line'

" Vim plugin: Text objects for indented blocks of lines
Plug 'kana/vim-textobj-indent'

" A custom text object for selecting ruby blocks.
Plug 'nelstrom/vim-textobj-rubyblock'

"


"  COLOR THEMES (reduced to commonly used ones for faster startup)

Plug 'morhetz/gruvbox'
" brogrammatrix is in colors/ directory - no plugin needed
" Uncomment below if you need additional themes:
" Plug 'nanotech/jellybeans.vim'
" Plug 'KeitaNakamura/neodark.vim'
" Plug 'marciomazza/vim-brogrammer-theme'

"


"  MISC
"
" Switch between single-line and multiline forms of code
" https://github.com/AndrewRadev/splitjoin.vim
Plug 'AndrewRadev/splitjoin.vim'


"
" open files with vim file:123
Plug 'bogado/file-line'
"

"  TComment
" :TComment works like a toggle, i.e., it will comment out text that
" contains uncommented lines, and it will uncomment already
" commented text (i.e. text that contains no uncommented lines).
Plug 'tomtom/tcomment_vim'
"

"  characterize

" In Vim, pressing ga on a character reveals its representation in decimal,
" octal, and hex. Characterize.vim modernizes this with the following additions:
"
" * Unicode character names: U+00A9 COPYRIGHT SYMBOL
" * Vim digraphs (type after <C-K> to insert the character): Co, cO
" * Emoji codes: :copyright:
" * HTML entities: &copy;
"
" https://github.com/tpope/vim-characterize
Plug 'tpope/vim-characterize'
"

"  ack.vim
" https://github.com/vim-scripts/ack.vim
Plug 'mileszs/ack.vim'
"

"  tabular
" https://github.com/godlygeek/tabular.git
" Technically, we'll use my fork since upstream doesnt tag ;_;
Plug 'godlygeek/tabular'
"

"

"  https://github.com/tpope/vim-unimpaired
Plug 'tpope/vim-unimpaired'
"

"  vim-smartinput
" *smartinput* is a Vim plugin to provide smart input assistant.
" Whenever you write a text, especially source code, you have to input and deal
" with pairs of punctuations such as (), [], {}, and so on. This plugin
" provides various input assistants for such characters according to the current
" context by default, and you can define your own rules to how the smart input
" assistant behaves in Insert mode and Command-line mode.
Plug 'kana/vim-smartinput'
"

"  vim-closetag
" Auto close (X)HTML tags
Plug 'alvan/vim-closetag'
"

"  vim-grex
" *grex* is a Vim plugin to provide useful commands to operate on
" lines matched to the last search pattern
Plug 'kana/vim-grex'
"

"  obsession
" obsession.vim: continuously updated session files
Plug 'tpope/vim-obsession'
"

"  vimroom
" Simulating a vaguely WriteRoom-like environment in Vim
Plug 'mikewest/vimroom'
"

"  vim-visual-star-search
" Start a * or " search from a visual block
" see also http://vimcasts.org/episodes/search-for-the-selected-text/
Plug 'nelstrom/vim-visual-star-search'
"

"  vim-signature
" Plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'
"

"  vim-airline
" lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline'
let g:airline_powerline_fonts=1
"

"  easymotion
" EasyMotion provides a much simpler way to use some motions in vim. It takes
" the <number> out of <number>w or <number>f{char} by highlighting all possible
" choices and allowing you to press one key to jump directly to the target.
" https://github.com/Lokaltog/vim-easymotion
Plug 'Lokaltog/vim-easymotion'
"

"  emojis
Plug 'junegunn/vim-emoji'
"

"  vim-abolish: Easily search for, substitute, and abbreviate multiple variants of a word
" https://github.com/tpope/vim-abolish
Plug 'tpope/vim-abolish'
"

"  open-browser.vim: Open URI with your favorite browser from your most favorite editor
" https://github.com/tyru/open-browser.vim
Plug 'tyru/open-browser.vim'
"

"  open-browser-github.vim: Open GitHub URL of current file, etc. from Vim editor
" https://github.com/tyru/open-browser-github.vim
Plug 'tyru/open-browser-github.vim'
"


"  /MISC


"  Ctags
Plug 'ludovicchabant/vim-gutentags'
"

"  Neomake
Plug 'neomake/neomake'
"

"  Tests

" vim-dispatch
" Leverage the power of Vim's compiler plugins without being bound by
" synchronicity. Kick off builds and test suites using one of several
" asynchronous adapters (including tmux, screen, iTerm, Windows, and a headless
" mode), and when the job completes, errors will be loaded and parsed
" automatically.
" https://github.com/tpope/vim-dispatch
Plug 'tpope/vim-dispatch'

" see https://github.com/janko-m/vim-test
Plug 'janko-m/vim-test'
"

"  SYNTAX CHECKING

"  Syntastic
" https://github.com/scrooloose/syntastic
Plug 'scrooloose/syntastic', { 'tag': '3.10.0' }
"

"  HCL (lazy load for terraform/hcl files)
Plug 'b4b4r07/vim-hcl', { 'for': ['hcl', 'terraform'] }
Plug 'fatih/vim-hclfmt', { 'for': ['hcl', 'terraform'] }
"

"

"  Code formatting
" Provide easy code formatting in Vim by integrating existing code formatters.
" https://github.com/Chiel92/vim-autoformat
Plug 'Chiel92/vim-autoformat'
Plug 'hashivim/vim-terraform'
"

"  Distraction-free writing (lazy load on command)

" Goyo - Distraction-free writing in Vim.
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
" Limelight - Hyper-focused writing in Vim.
Plug 'junegunn/limelight.vim', { 'on': ['Limelight', 'Limelight!', 'Limelight!!'] }
"


"  SEARCH

Plug 'Shougo/vimproc.vim', { 'do': 'make' }

" Telescope and its dependencies
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
" Optional but recommended for better performance
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Unite and vimproc
" see https://medium.com/@crashybang/supercharge-vim-with-fzf-and-ripgrep-d4661fc853d2#.y2pz1mipy
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all', 'tag': 'v0.56.3' }
Plug 'junegunn/fzf.vim', { 'commit': '279e1ec' }

" Treesitter powered spellchecker
" DISABLED: Compatibility issue with Neovim 0.11.5 - get_query nil error
" Plug 'lewis6991/spellsitter.nvim'

" https://github.com/tmux-plugins/vim-tmux
Plug 'tmux-plugins/vim-tmux'

"
"https://github.com/tmux-plugins/vim-tmux  TO TEST SOME DAY
"
" All of kana's plugins, especially:
" kana/vim-smarttill
" kana/vim-smartword
"
" https://github.com/szw/vim-ctrlspace
" http://majutsushi.github.com/tagbar/
" https://github.com/xolox/vim-easytags
" Plug 'tpope/tslime.vim' " https://g-railsithub.com/kikijump/tslime.vim
" Plug 'ngn/vim-buffing-wheel' " https://github.com/ngn/vim-buffing-wheel
"

call plug#end()
