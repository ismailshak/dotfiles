# macOS

The modules `bootstrap.sh` runs, in order.

- `preflight` - Xcode CLT, internet, sudo
- `packages` - Homebrew formulas, mise, gh, dotfiles, terminfo
- `settings` - `defaults write` commands
- `apps` - casks, fonts, icons
- `repos` - clone GitHub repos, set up neovim
- `manual` - list the steps done by hand
