.PHONY: all install save-snapshot restore-snapshot make_dirs help

# Default target
all: install README.markdown

# Help target to display available commands
help:
	@echo "Makefile for Neovim configuration management"
	@echo "Usage:"
	@echo "  make all                - Install configuration and update README"
	@echo "  make install            - Set up symlinks and restore plugin snapshot"
	@echo "  make save-snapshot      - Save current plugin state to snapshot.vim"
	@echo "  make restore-snapshot   - Restore plugins from snapshot.vim"
	@echo "  make make_dirs          - Create necessary directories for Vim"

# Install target to set up symlinks and restore plugin snapshot
install: ~/.vimrc ~/.gvimrc init.vim restore-snapshot make_dirs

# Create symlink for .vimrc
~/.vimrc:
	@echo "Linking vimrc to ~/.vimrc"
	ln -sf $(CURDIR)/vimrc ~/.vimrc

# Create symlink for .gvimrc
~/.gvimrc:
	@echo "Linking gvimrc to ~/.gvimrc"
	ln -sf $(CURDIR)/gvimrc ~/.gvimrc

# Create symlink for Neovim configuration directory
~/.config/nvim:
	@echo "Setting up Neovim configuration directory"
	mkdir -p ~/.config
	ln -sf $(CURDIR) $@

# Create symlink for init.vim
init.vim: vimrc ~/.config/nvim
	@echo "Linking vimrc to init.vim"
	ln -sf $< $@

# Save current plugin state to snapshot.vim
save-snapshot:
	@echo "Saving current plugin state to snapshot.vim"
	nvim -c "PlugSnapshot! snapshot.vim" -c "qall"

# Restore plugins from snapshot.vim
restore-snapshot:
	@echo "Restoring plugins from snapshot.vim"
	nvim -c "PlugClean!" -S snapshot.vim -c "qall"

# Create necessary directories for Vim
make_dirs:
	@echo "Creating necessary directories for Vim"
	mkdir -p ~/.cache/vim/undo \
		~/.cache/vim/swap \
		~/.cache/vim/backup
