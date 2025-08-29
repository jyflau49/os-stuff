# OS Bootstrap Toolkit

A collection of tools and scripts for rapidly setting up fresh VMs with standardized configurations.

## Files

- **`startup-script.sh`** - Complete VM setup: security updates, shell config, maintenance automation
- **`bashrc.template`** - Portable `.bashrc` with conditional tool support
- **`bash_local.template`** - Template for host-specific customizations
- **`linode-bootstrap.sh`** - Minimal wrapper for Linode StackScript

## Quick Deployment

### Clone and Run
```bash
# On new Ubuntu VM (as root):
git clone https://github.com/jyflau49/os-stuff.git /tmp/os-stuff
cd /tmp/os-stuff
chmod +x startup-script.sh
./startup-script.sh
```

## What Gets Configured

### 🔒 System Security & Updates
- **Strict error handling** - Scripts fail fast on errors
- **Package updates** - Full system upgrade on first run
- **Unattended upgrades** - Automatic security updates
- **Scheduled reboots** - 2:00 AM when kernel updates require it
- **Package cleanup** - Weekly removal of unused packages

### 🐚 Shell Environment
- **Portable `.bashrc`** - Works across different VMs and tool installations
- **Conditional tool support** - Aliases/completions only load if tools exist
- **Host-specific configs** - `.bash_local` for per-VM customizations
- **Smart completions** - kubectl, terraform, docker, etc. (when installed)

### 🔧 Linode Bootstrap Integration
- **StackScript ready** - `linode-bootstrap.sh` clones repo and runs setup
- **Git-based updates** - Easy to maintain and version control
- **Minimal StackScript** - Keeps Linode StackScript simple and flexible

## Post-Installation

### Customize for Your Environment
```bash
# Edit /root/.bash_local with host-specific settings, for example:
export KUBECONFIG='/path/to/kubeconfig.yaml'
export VAULT_ADDR='https://vault.example.com'
export GCP_PROJECT_ID="your-project"
alias k='kubectl'
alias t='terraform'

# Reload configuration
source ~/.bashrc
```

## Compatibility

- **Tested**: Ubuntu 20.04, 22.04, 24.04 LTS
- **Requirements**: sudo, internet
- **Dependencies**: Standard Ubuntu repositories only

## Security Considerations

- ⚠️ **Root access required** for system configuration
- ⚠️ **Automatic reboots enabled** - plan maintenance windows accordingly
- ✅ **Security-only updates** by default (not all package updates)
- ✅ **No external dependencies** beyond standard Ubuntu packages
