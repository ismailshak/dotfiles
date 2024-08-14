sync_dots:
	[ -e ~/.zsh ] || ln -s $(PWD)/.zsh ~/.zsh
	[ -e ~/.gitconfig ] || ln -s $(PWD)/.gitconfig ~/.gitconfig
	[ -e ~/.mailmap ] || ln -s $(PWD)/.mailmap ~/.mailmap
	[ -e ~/.tmux.conf ] || ln -s $(PWD)/.tmux.conf ~/.tmux.conf
	[ -e ~/.hushlogin ] || ln -s $(PWD)/.hushlogin ~/.hushlogin
	
	@for item in /Users/shak/code/dotfiles/.config/*; do \
	target="$$HOME/.config/$$(basename $$item)"; \
	[ -e "$$target" ] || ln -s "$$item" "$$target"; \
	done

	touch $(HOME)/.zshrc
	grep -qxF '[ -f ~/.zsh/config.zsh ] && source ~/.zsh/config.zsh' $(HOME)/.zshrc || echo '[ -f ~/.zsh/config.zsh ] && source ~/.zsh/config.zsh' >> $(HOME)/.zshrc


sync_icons:
	cp -n ./icons/wezterm.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns
	rm /var/folders/*/*/*/com.apple.dock.iconcache
	rm -r /var/folders/*/*/*/com.apple.iconservices*

sync_fonts:
	-cp -vn ./fonts/* ~/Library/Fonts/
