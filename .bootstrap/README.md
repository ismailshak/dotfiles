# Bootstrap

Set up a fresh Mac or Debian server.

macOS:

```sh
curl -fsSL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/install.sh | sh
```

Debian:

```sh
wget -qO- https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/install.sh | sh
```

[`install.sh`](./install.sh) clones this repo to `/tmp/dotfiles` and runs `macos/bootstrap.sh` or `debian/bootstrap.sh`, depending on the OS. `bootstrap.sh` runs the platform's modules in order. Output goes to `/tmp/bootstrap-log.log`.

To run a single module, add `-s -- --only <module>` after `sh` in the install command:

```sh
curl -fsSL https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/install.sh | sh -s -- --only <module>
```

If the repo is already cloned, `bash <repo>/.bootstrap/<platform>/bootstrap.sh --only <module>` does the same without pulling.
