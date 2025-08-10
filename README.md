# Ubuntu VM Setup Templates

This repository contains standardized configuration templates for new Ubuntu VMs.

## Files

- **`startup-script.sh`** - Main setup script for new Ubuntu VMs
- **`bashrc.template`** - Portable `.bashrc` configuration
- **`bash_local.template`** - Template for host-specific bash configurations

## Quick Deployment

### Method 1: Clone and Run (Recommended)
```bash
# On new Ubuntu VM (as root):
git clone <your-repo-url> /tmp/os-stuff
cd /tmp/os-stuff
chmod +x startup-script.sh
./startup-script.sh
# Then customize /root/.bash_local for this host
```

### Method 2: Direct Download and Run
```bash
# Download and run startup script directly:
curl -fsSL <raw-github-url>/startup-script.sh | sudo bash
```

## What the Startup Script Does

### System Updates & Security
- ✅ Enables strict bash error handling
- ✅ Updates package lists and upgrades existing packages
- ✅ Installs and configures unattended-upgrades for automatic security updates
- ✅ Sets up automatic reboots at 2:00 AM when needed
- ✅ Enables APT periodic maintenance (autoremove, autoclean)

### Shell Environment
- ✅ Installs portable `.bashrc` with conditional tool support
- ✅ Creates `.bash_local` template for host-specific customizations
- ✅ Sets up completion for kubectl, terraform, and other tools (when available)

## Post-Installation

### 1. Customize `.bash_local`
Edit `/root/.bash_local` with host-specific settings:
```bash
# Example customizations:
export KUBECONFIG='/path/to/your/kubeconfig.yaml'
export VAULT_ADDR='https://your-vault.example.com'
export GCP_PROJECT_ID="your-project-id"
alias ssh-prod='ssh user@prod-server.example.com'
```

### 2. Reload Shell Configuration
```bash
source ~/.bashrc
# or simply start a new shell session
```

## Features

### Automatic Updates
- **Security updates**: Applied automatically
- **Automatic reboots**: Scheduled for 2:00 AM when required
- **Package cleanup**: Removes unused packages weekly

### Portable Shell Environment
- **Tool detection**: Aliases and completions only load if tools are installed
- **Host-specific configs**: Separate file for machine-specific settings
- **No hard-coded paths**: Won't break on VMs with different directory structures

## Customization

### Adding More Tools to Startup Script
Edit `startup-script.sh` to install additional packages:
```bash
# Add after the unattended-upgrades installation:
echo "[INFO] Installing additional tools..."
apt-get install -y htop btop vim git curl wget jq
```

### Adding More Aliases/Functions
Add to your local `.bash_local` file or modify the `bashrc.template` for global changes.

## Compatibility

- **Tested on**: Ubuntu 20.04, 22.04, 24.04
- **Requires**: Root access for initial setup
- **Dependencies**: Standard Ubuntu packages only

## Security Notes

- Script requires root access for system configuration
- Automatic reboots enabled - ensure this fits your maintenance windows
- Only security updates are applied automatically by default
- SSH and firewall hardening not included (can be added incrementally)
