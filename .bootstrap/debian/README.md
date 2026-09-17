# Debian

The modules `bootstrap.sh` runs, in order.

- `preflight` - debian, internet, sudo
- `packages` - apt, GitHub releases, mise and its tools for all users, docker, gh, dotfiles, terminfo
- `users` - sudo and docker groups, `apps` service user, zsh
- `access` - authorized key, sshd hardening, mDNS, tailscale
- `secrets` - age keys for sops
- `apps` - the compose stack as a systemd service
- `health` - unattended upgrades, ufw, journald config and docker config
- `backups` - restic timer, backup and restore scripts

## mise

mise tools are installed for all users in `/usr/local/share/mise`, owned by root. `/etc/mise/config.toml` links to `.config/mise/config.toml` in the dotfiles clone. root runs restic and the `apps` user runs sops. `/usr/local/bin/restic` and `/usr/local/bin/sops` link into that install for them.

- Upgrade: `sudo mise upgrade`
- Install a tool added to the config: `sudo mise install --system && sudo mise reshim --system`
- Remove an old version: `sudo mise uninstall <tool>@<version>`

A plain `mise install` without sudo puts a second copy of the tool under `~/.local/share/mise`.
