# macOS

Bootstrap a fresh Mac.

```sh
curl -fsSL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/macos/install.sh | sh
```

`install.sh` clones this repo to `/tmp/dotfiles` and runs `bootstrap.sh`, which runs the modules in order. Output goes to `/tmp/bootstrap-log.log`.

- `preflight` - Xcode CLT, internet, sudo
- `packages` - Homebrew formulas, mise, gh, dotfiles, terminfo
- `settings` - `defaults write` commands
- `apps` - casks, fonts, icons
- `repos` - clone GitHub repos, set up neovim

Run a single module with `bash /tmp/dotfiles/.bootstrap/macos/bootstrap.sh --only <module>`.
