#!/bin/bash

# Linode StackScript Bootstrap
# This minimal script clones the os-stuff repo and runs the full setup
# Keeps StackScript simple and allows git-based updates

set -euo pipefail
trap 'echo "[ERROR] Bootstrap failed at line $LINENO" >&2' ERR

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Starting Linode VM bootstrap..."

# Ensure we're running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install git if not present
if ! command -v git >/dev/null; then
    echo "[INFO] Installing git..."
    apt-get update
    apt-get install -y git
fi

# Clone the os-stuff repository
REPO_URL="https://github.com/jyflau49/os-stuff.git"
CLONE_DIR="/tmp/os-stuff-bootstrap"

echo "[INFO] Cloning os-stuff repository..."
if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR"
fi

git clone "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR"

# Make startup script executable and run it
echo "[INFO] Running full startup script from repository..."
chmod +x startup-script.sh
./startup-script.sh

# Cleanup
echo "[INFO] Cleaning up bootstrap files..."
cd /
rm -rf "$CLONE_DIR"

echo "[INFO] Linode VM bootstrap complete!"
echo "[INFO] Please customize /root/.bash_local for this host."
