#!/usr/bin/env bash
#
# .debian/modules/health.sh - configure system health features like auto-updates, firewall, and logging.

LAN_IFACE="$(ip route show default | awk '{print $5}' | head -n1)"
LAN_SUBNET="$(ip route show dev "$LAN_IFACE" proto kernel | awk '{print $1}' | head -n1)"

enable_unattended_upgrades() {
  sudo apt-get install -y unattended-upgrades
  install_system_file config/apt/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
}

ufw_active() { sudo ufw status 2>/dev/null | grep -q '^Status: active'; }

configure_firewall() {
  sudo apt-get install -y ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow from 100.64.0.0/10 to any port 22 proto tcp # tailnet
  sudo ufw allow from "$LAN_SUBNET" to any port 22 proto tcp # your LAN
  sudo ufw --force enable
}

configure_logging() {
  install_system_file config/systemd/journald-00-size.conf /etc/systemd/journald.conf.d/00-size.conf
  sudo systemctl restart systemd-journald
  install_system_file config/docker/daemon.json /etc/docker/daemon.json
  sudo systemctl restart docker
}

run_health() {
  phase "System Health"
  step "auto-updates" test -f /etc/apt/apt.conf.d/20auto-upgrades -- enable_unattended_upgrades
  step "firewall" ufw_active -- configure_firewall
  step "logging" false -- configure_logging
}
