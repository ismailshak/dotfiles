# Debian

The modules `bootstrap.sh` runs, in order.

- `preflight` - debian, internet, sudo
- `packages` - apt, GitHub releases, mise, docker, gh, dotfiles, terminfo
- `users` - sudo and docker groups, `apps` service user, zsh
- `access` - authorized key, sshd hardening, mDNS, tailscale
- `secrets` - age keys for sops
- `apps` - the compose stack as a systemd service
- `health` - unattended upgrades, ufw, journald and docker log limits
- `backups` - restic timer, backup and restore scripts
