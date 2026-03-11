# OS Bootstrap Toolkit

Automated Ubuntu VM setup with security hardening, shell configuration, and modern CLI tools.

**Quick start:**
```bash
curl -fsSL https://raw.githubusercontent.com/jyflau49/os-stuff/main/startup-script.sh | sudo bash
```

## What It Does

**System Security**
- Automatic security updates with unattended-upgrades
- Scheduled reboots at 2:00 AM for kernel updates
- Weekly package cleanup
- Kernel lockdown in `integrity` mode (restricts unsigned kernel module loading)

**Shell Environment**
- Portable `.bashrc` with conditional tool support (kubectl, terraform, docker, etc.)
- Host-specific `.bashrc_local` for per-VM customizations
- Modern CLI tools: bat, zoxide, ripgrep

**Optional Tools**
Uncomment the relevant sections in `startup-script.sh` to enable.
- Docker installation (official script)
- Doppler CLI for secrets management

## Manual Installation

```bash
git clone https://github.com/jyflau49/os-stuff.git /tmp/os-stuff
cd /tmp/os-stuff
chmod +x startup-script.sh
./startup-script.sh
```

## Post-Installation

Customize `/root/.bashrc_local` for host-specific settings:
```bash
export KUBECONFIG='/path/to/kubeconfig.yaml'
export VAULT_ADDR='https://vault.example.com'
alias k='kubectl'
```

Then reboot to apply kernel lockdown:
```bash
reboot
```

## Compatibility

- Ubuntu 20.04, 22.04, 24.04 LTS
- Requires root access and internet connection
- Automatic reboots enabled - plan maintenance windows accordingly
