.PHONY: all install save-snapshot restore-snapshot make_dirs help

# Default target
all: install

# Help target to display available commands
help:
	@echo "Makefile for Neovim configuration management"
	@echo "Usage:"
	@echo "  make all                - Install configuration and restore snapshot"
	@echo "  make install            - Restore plugin snapshot and create dirs"
	@echo "  make save-snapshot      - Save current plugin state to snapshot.vim"
	@echo "  make restore-snapshot   - Restore plugins from snapshot.vim"
	@echo "  make make_dirs          - Create necessary directories for Vim"

# Install target (symlinks are handled by setup-symlinks.sh)
install: restore-snapshot make_dirs

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
