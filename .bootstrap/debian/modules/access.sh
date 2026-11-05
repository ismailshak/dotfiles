#!/usr/bin/env bash
#
# .bootstrap/debian/modules/access.sh - configure SSH and Tailscale access
#
# (depends on tailscale [packages.sh])

LAN_IP="$(hostname -I | awk '{print $1}')"
LAN_IF="$(ip -o route show default | awk '{print $5; exit}')"
SSHD_HARDENING="/etc/ssh/sshd_config.d/99-hardening.conf"
AVAHI_CONF="/etc/avahi/avahi-daemon.conf"

# Linux lets avahi join the mDNS group on at most 20 IPv4 interfaces (net.ipv4.igmp_max_memberships).
# Every compose network adds a bridge, and once they take all 20 the LAN interface can't join, so <hostname>.local stops resolving over IPv4.
mdns_lan_only() {
  sudo sed -i "s/^#\?allow-interfaces=.*/allow-interfaces=$LAN_IF/" "$AVAHI_CONF" &&
    grep -qx "allow-interfaces=$LAN_IF" "$AVAHI_CONF" &&
    sudo systemctl restart avahi-daemon
}

authorize_key() {
  mkdir -p "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
  touch "$USER_HOME/.ssh/authorized_keys"
  chmod 600 "$USER_HOME/.ssh/authorized_keys"
  grep -qF "$PUBKEY" "$USER_HOME/.ssh/authorized_keys" || echo "$PUBKEY" >>"$USER_HOME/.ssh/authorized_keys"
}

harden_sshd() {
  install_system_file config/ssh/99-hardening.conf "$SSHD_HARDENING"
  sudo sshd -t # validate before restart
  sudo systemctl reload ssh
}

tailscale_up() {
  command -v tailscale &>/dev/null || curl -fsSL https://tailscale.com/install.sh | sh
  install_system_file config/sysctl/99-tailscale.conf /etc/sysctl.d/99-tailscale.conf
  sudo sysctl -p /etc/sysctl.d/99-tailscale.conf >/dev/null
  sudo tailscale up --ssh --advertise-exit-node --authkey="$TS_AUTHKEY"
}

run_access() {
  phase "SSH & Tailscale"
  local PUBKEY TS_AUTHKEY
  note "run: ssh-keygen -t ed25519 -f ~/.ssh/id_atlas -C \"atlas@$(hostname)\""

  ask "Your SSH public key (cat ~/.ssh/id_atlas.pub on your machine):" PUBKEY
  step "authorized_keys" grep -qsF "$PUBKEY" "$USER_HOME/.ssh/authorized_keys" -- authorize_key
  step "sshd hardening" test -f "$SSHD_HARDENING" -- harden_sshd
  step "mdns" systemctl is-active --quiet avahi-daemon -- sudo systemctl enable --now avahi-daemon
  step "mdns on $LAN_IF only" grep -qx "allow-interfaces=$LAN_IF" "$AVAHI_CONF" -- mdns_lan_only

  warn "Do NOT close this session. Verify SSH access from a second terminal:"
  note "  • ${USERNAME}@$LAN_IP"
  note "  • ${USERNAME}@$(hostname).local"

  if ! tailscale status &>/dev/null; then
    ask -s "Tailscale one-shot auth key:" TS_AUTHKEY
  fi

  step "tailscale" tailscale status -- tailscale_up
}
