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

# Create .bashrc_local for host-specific configurations
if [ ! -f "/root/.bashrc_local" ]; then
    echo "[INFO] Creating .bashrc_local for host-specific configurations..."
    if [ -f "$SCRIPT_DIR/bashrc_local.template" ]; then
        cp "$SCRIPT_DIR/bashrc_local.template" /root/.bashrc_local
        echo "[INFO] Copied .bashrc_local template from repository."
        echo "[INFO] Please customize /root/.bashrc_local for this host."
    else
        echo "[WARN] bashrc_local.template not found in $SCRIPT_DIR"
        echo "[WARN] Please manually create /root/.bashrc_local for host-specific configs."
    fi
else
    echo "[INFO] .bashrc_local already exists, skipping creation."
fi

# Optional: Install Docker (uncomment to enable)
# echo "[INFO] Installing Docker..."
# if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh; then
#     if sh /tmp/get-docker.sh; then
#         echo "[INFO] Docker installed successfully."
#         rm -f /tmp/get-docker.sh
#     else
#         echo "[WARN] Docker installation failed, continuing..."
#         rm -f /tmp/get-docker.sh
#     fi
# else
#     echo "[WARN] Failed to download Docker installation script, skipping..."
# fi

# Optional: Install Doppler CLI (uncomment to enable)
# echo "[INFO] Installing Doppler CLI..."
# if apt-get install -y apt-transport-https ca-certificates curl gnupg; then
#     if curl -sLf --retry 3 --tlsv1.2 --proto "=https" \
#         'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | \
#         gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg; then
#         echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | \
#             tee /etc/apt/sources.list.d/doppler-cli.list >/dev/null
#         apt-get update
#         if apt-get install -y doppler; then
#             echo "[INFO] Doppler CLI installed successfully."
#         else
#             echo "[WARN] Doppler CLI installation failed, continuing..."
#         fi
#     else
#         echo "[WARN] Failed to add Doppler GPG key, skipping..."
#     fi
# else
#     echo "[WARN] Failed to install Doppler prerequisites, skipping..."
# fi

# Install modern Rust-based CLI utilities
echo "[INFO] Installing modern CLI utilities (bat, zoxide, ripgrep)..."
if apt-get install -y bat zoxide ripgrep; then
    echo "[INFO] Modern CLI utilities installed successfully."
    # Create bat symlink if needed (Ubuntu packages it as batcat)
    if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
        ln -sf /usr/bin/batcat /usr/local/bin/bat
        echo "[INFO] Created 'bat' symlink for batcat."
    fi
else
    echo "[WARN] Failed to install some CLI utilities, continuing..."
fi

# Linux Kernel Lockdown: enforce integrity mode via GRUB
echo "[INFO] Configuring kernel lockdown mode (integrity)..."
GRUB_DEFAULT_FILE="/etc/default/grub"
if [ -f "$GRUB_DEFAULT_FILE" ]; then
    if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$GRUB_DEFAULT_FILE"; then
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="lockdown=integrity"/' "$GRUB_DEFAULT_FILE"
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="lockdown=integrity"' >> "$GRUB_DEFAULT_FILE"
    fi
    echo "[INFO] GRUB_CMDLINE_LINUX_DEFAULT set to: lockdown=integrity"
    update-grub
    echo "[INFO] GRUB updated successfully. A reboot is required to apply kernel lockdown."
else
    echo "[WARN] $GRUB_DEFAULT_FILE not found, skipping lockdown configuration."
fi

echo ""
echo "[INFO] =========================================="
echo "[INFO] Ubuntu VM setup complete!"
echo "[INFO] =========================================="
echo "[INFO] Next steps:"
echo "[INFO]   1. Customize /root/.bashrc_local for host-specific settings"
echo "[INFO]   2. Reload shell: source ~/.bashrc"
echo "[INFO]   3. Review installed tools: bat, zoxide (z), ripgrep (rg)"
echo "[INFO]   4. Reboot to apply kernel lockdown=integrity: reboot"
echo "[INFO] =========================================="
