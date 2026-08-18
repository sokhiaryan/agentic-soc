#!/usr/bin/env bash
# Install PowerShell Core from Microsoft's Ubuntu 24.04 package repository.
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo 'Run as your normal sudo-capable user, not as root.' >&2
  exit 1
fi

. /etc/os-release
if [[ ${ID:-} != ubuntu || ${VERSION_ID:-} != 24.04 ]]; then
  echo "This script currently supports Ubuntu 24.04 only; detected: ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

package_file=$(mktemp /tmp/packages-microsoft-prod.XXXXXX.deb)
trap 'rm -f "$package_file"' EXIT
curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o "$package_file"
sudo dpkg -i "$package_file"
sudo apt update
sudo apt install -y powershell
pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'
