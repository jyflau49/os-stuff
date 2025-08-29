#!/bin/bash

# Strict mode: exit on error, undefined vars, pipe failures
set -euo pipefail

# Error trap for debugging
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Set noninteractive frontend early to suppress GUI prompts
export DEBIAN_FRONTEND=noninteractive

# Ensure the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "[INFO] Starting Ubuntu VM setup script..."

# Update the package list
echo "[INFO] Updating package lists..."
apt-get update

# Upgrade existing packages first
echo "[INFO] Upgrading existing packages..."
apt-get -y upgrade

# Clean up after upgrade
echo "[INFO] Cleaning up after upgrade..."
apt-get -y autoremove
apt-get -y autoclean

# Install unattended-upgrades package with automatic yes to prompts
echo "[INFO] Installing unattended-upgrades..."
apt-get install -y unattended-upgrades

# Enable unattended-upgrades without any prompts
echo "[INFO] Configuring unattended-upgrades..."
dpkg-reconfigure -f noninteractive unattended-upgrades

# Configure unattended-upgrades for security updates and automatic reboots
echo "[INFO] Writing unattended-upgrades configuration..."
install -b -m 0644 /dev/null /etc/apt/apt.conf.d/50unattended-upgrades
cat <<'EOF' | tee /etc/apt/apt.conf.d/50unattended-upgrades >/dev/null
Unattended-Upgrade::Origins-Pattern {
    "origin=Ubuntu,codename=${distro_codename}-security";
    // Optional: uncomment for regular updates (not just security)
    // "origin=Ubuntu,codename=${distro_codename},label=Ubuntu";
    // Optional: Ubuntu Pro ESM updates
    // "origin=UbuntuESMApps,codename=${distro_codename}-apps-security";
    // "origin=UbuntuESM,codename=${distro_codename}-infra-security";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
// Optional: email notifications (uncomment and set email)
// Unattended-Upgrade::Mail "root";
// Unattended-Upgrade::MailOnlyOnError "true";
EOF

# Configure APT automatic updates
echo "[INFO] Writing APT periodic configuration..."
install -b -m 0644 /dev/null /etc/apt/apt.conf.d/20auto-upgrades
cat <<'EOF' | tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Autoremove "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Enable and start unattended-upgrades service and timers
echo "[INFO] Enabling unattended-upgrades services..."
systemctl enable --now unattended-upgrades.service || true
systemctl enable --now apt-daily.timer || true
systemctl enable --now apt-daily-upgrade.timer || true

# Run unattended-upgrades in dry-run mode to test the configuration
echo "[INFO] Testing unattended-upgrades configuration..."
if command -v unattended-upgrades >/dev/null; then
    unattended-upgrades --dry-run --debug || echo "[WARN] Dry-run test failed, but continuing..."
fi

echo "[INFO] Unattended-upgrades configuration is complete."

# Setup portable bash configuration
echo "[INFO] Setting up portable bash configuration..."

# Copy portable .bashrc if this script is run from the os-stuff directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/bashrc.template" ]; then
    echo "[INFO] Installing portable .bashrc template..."
    cp "$SCRIPT_DIR/bashrc.template" /root/.bashrc
    echo "[INFO] Portable .bashrc installed."
fi

# Create .bash_local for host-specific configurations
if [ ! -f "/root/.bash_local" ]; then
    echo "[INFO] Creating .bash_local for host-specific configurations..."
    if [ -f "$SCRIPT_DIR/bash_local.template" ]; then
        cp "$SCRIPT_DIR/bash_local.template" /root/.bash_local
        echo "[INFO] Copied .bash_local template from repository."
        echo "[INFO] Please customize /root/.bash_local for this host."
    else
        echo "[WARN] bash_local.template not found in $SCRIPT_DIR"
        echo "[WARN] Please manually create /root/.bash_local for host-specific configs."
    fi
else
    echo "[INFO] .bash_local already exists, skipping creation."
fi
