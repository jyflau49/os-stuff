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

**Shell Environment**
- Portable `.bashrc` with conditional tool support (kubectl, terraform, docker, etc.)
- Host-specific `.bash_local` for per-VM customizations
- Modern CLI tools: bat, zoxide, ripgrep

**Optional Integrations**
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

Customize `/root/.bash_local` for host-specific settings:
```bash
export KUBECONFIG='/path/to/kubeconfig.yaml'
export VAULT_ADDR='https://vault.example.com'
alias k='kubectl'
```

## Linode StackScript

Use `linode-bootstrap.sh` as a StackScript for automated deployment.

## Compatibility

- Ubuntu 20.04, 22.04, 24.04 LTS
- Requires root access and internet connection
- Automatic reboots enabled - plan maintenance windows accordingly
