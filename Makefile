CURRENT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

sync_dots:
	[ -e ~/.zsh ] || ln -s $(CURRENT_DIR)/.zsh ~/.zsh
	[ -e ~/.gitconfig ] || ln -s $(CURRENT_DIR)/.gitconfig ~/.gitconfig
	[ -e ~/.mailmap ] || ln -s $(CURRENT_DIR)/.mailmap ~/.mailmap
	[ -e ~/.tmux.conf ] || ln -s $(CURRENT_DIR)/.tmux.conf ~/.tmux.conf
	[ -e ~/.hushlogin ] || ln -s $(CURRENT_DIR)/.hushlogin ~/.hushlogin
	
	@for item in /Users/shak/code/dotfiles/.config/*; do \
	target="$$HOME/.config/$$(basename $$item)"; \
	[ -e "$$target" ] || ln -s "$$item" "$$target"; \
	done

	touch $(HOME)/.zshrc
	grep -qxF '[ -f ~/.zsh/config.zsh ] && source ~/.zsh/config.zsh' $(HOME)/.zshrc || echo '[ -f ~/.zsh/config.zsh ] && source ~/.zsh/config.zsh' >> $(HOME)/.zshrc


sync_icons:
	cp -n $(CURRENT_DIR)/icons/wezterm.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns
	rm /var/folders/*/*/*/com.apple.dock.iconcache
	rm -r /var/folders/*/*/*/com.apple.iconservices*

sync_fonts:
	-cp -vn $(CURRENT_DIR)/fonts/* ~/Library/Fonts/
