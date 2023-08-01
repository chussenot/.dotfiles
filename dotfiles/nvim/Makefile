all: install README.markdown

install: ~/.vimrc ~/.gvimrc init.vim restore-snapshot make_dirs

~/.vimrc:
	ln -s $(CURDIR)/vimrc ~/.vimrc

~/.gvimrc:
	ln -s $(CURDIR)/gvimrc ~/.gvimrc

~/.config/nvim:
	mkdir -p ~/.config
	ln -sf $(CURDIR) $@

init.vim: vimrc ~/.config/nvim
	ln -sf $< $@

save-snapshot:
	nvim -c "PlugSnapshot! snapshot.vim" -c "qall"

restore-snapshot:
	nvim -c "PlugClean!" -S snapshot.vim -c "qall"

configure_vim_sensible: make_dirs

make_dirs:
	mkdir -p ~/.cache/vim/undo \
		~/.cache/vim/swap \
		~/.cache/vim/backup \
		~/.cache/vim/undo \

README.markdown: plugs.vim
	./update_readme
