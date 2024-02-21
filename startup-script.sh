#!/bin/bash

# Ensure the script is running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Update the package list
apt-get update

# Install unattended-upgrades package with automatic yes to prompts
apt-get install -y unattended-upgrades

# Set noninteractive frontend for Debian-based operations (suppresses GUI prompts)
export DEBIAN_FRONTEND=noninteractive

# Enable unattended-upgrades without any prompts
dpkg-reconfigure -f noninteractive unattended-upgrades

# Configure unattended-upgrades for security updates and automatic reboots
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "18:00";
EOF

# Configure APT automatic updates
cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Run unattended-upgrades in dry-run mode to test the configuration
unattended-upgrades --dry-run --debug

echo "Unattended-upgrades configuration is complete."
