# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.2.0] - 2026-03-11

### Added
- Kernel lockdown in `integrity` mode via GRUB (`lockdown=integrity`)
  - Sets `GRUB_CMDLINE_LINUX_DEFAULT="lockdown=integrity"` in `/etc/default/grub`
  - Runs `update-grub` automatically after configuration
  - Restricts unsigned kernel module loading (LOCKDOWN_INTEGRITY)
  - Reboot reminder added to post-setup next steps

### Removed
- `linode-stackscript.sh` — no longer used; manual or curl-based installation is preferred

## [1.1.1] - 2025-12-01

### Fixed
- Improved error handling and `set -euo pipefail` strict mode
- Added error trap for debugging failed lines

## [1.1.0] - 2025-11-01

### Added
- Modern CLI utilities: `bat`, `zoxide`, `ripgrep`
- `bat` symlink for Ubuntu's `batcat` binary

## [1.0.0] - 2025-10-01

### Added
- Initial release: unattended-upgrades, bash configuration, optional Docker and Doppler CLI
