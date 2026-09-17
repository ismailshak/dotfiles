#!/usr/bin/env bash
#
# .bootstrap/debian/modules/health.sh - configure system health features like auto-updates, firewall, and logging.

LAN_IFACE="$(ip route show default | awk '{print $5}' | head -n1)"
LAN_SUBNET="$(ip route show dev "$LAN_IFACE" proto kernel | awk '{print $1}' | head -n1)"

APT_CONF_DIR="/etc/apt/apt.conf.d"

unattended_upgrades_current() {
  cmp -s config/apt/20auto-upgrades "$APT_CONF_DIR/20auto-upgrades" &&
    cmp -s config/apt/52unattended-upgrades-local "$APT_CONF_DIR/52unattended-upgrades-local"
}

enable_unattended_upgrades() {
  sudo apt-get install -y unattended-upgrades
  install_system_file config/apt/20auto-upgrades "$APT_CONF_DIR/20auto-upgrades"
  install_system_file config/apt/52unattended-upgrades-local "$APT_CONF_DIR/52unattended-upgrades-local"
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

JOURNALD_SIZE_CONF="/etc/systemd/journald.conf.d/00-size.conf"
DOCKER_DAEMON_JSON="/etc/docker/daemon.json"

limit_journal_size() {
  install_system_file config/systemd/journald-00-size.conf "$JOURNALD_SIZE_CONF"
  sudo systemctl restart systemd-journald
}

install_docker_daemon_config() {
  install_system_file config/docker/daemon.json "$DOCKER_DAEMON_JSON"
  sudo systemctl restart docker
}

run_health() {
  phase "System Health"
  step "auto-updates" unattended_upgrades_current -- enable_unattended_upgrades
  step "firewall" ufw_active -- configure_firewall
  step "journal size limit" cmp -s config/systemd/journald-00-size.conf "$JOURNALD_SIZE_CONF" -- limit_journal_size
  step "docker daemon config" cmp -s config/docker/daemon.json "$DOCKER_DAEMON_JSON" -- install_docker_daemon_config
}
