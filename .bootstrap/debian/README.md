# Debian

Bootstrap a fresh Debian server.

```sh
wget -qO- https://raw.githubusercontent.com/ismailshak/dotfiles/main/.bootstrap/debian/install.sh | sh
```

`install.sh` clones this repo to `/tmp/dotfiles` and runs `bootstrap.sh`, which runs the modules in order. Output goes to `/tmp/bootstrap-log.log`.

- `preflight` - debian, internet, sudo
- `packages` - apt, GitHub releases, mise, docker, gh, dotfiles, terminfo
- `users` - sudo and docker groups, `apps` service user, zsh
- `access` - authorized key, sshd hardening, mDNS, tailscale
- `secrets` - age keys for sops
- `apps` - the compose stack as a systemd service
- `health` - unattended upgrades, ufw, journald and docker log limits
- `backups` - restic timer, backup and restore scripts

Run a single module with `bash /tmp/dotfiles/.bootstrap/debian/bootstrap.sh --only <module>`.
