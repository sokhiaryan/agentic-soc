#!/usr/bin/env bash
# Install Docker Engine and the Compose v2 plugin from Docker's official APT repo.
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo 'Run this script as your normal sudo-capable user, not as root.' >&2
  exit 1
fi

. /etc/os-release
if [[ ${ID:-} != ubuntu ]]; then
  echo "This script supports Ubuntu only; detected: ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git jq
sudo usermod -aG docker "$USER"

echo 'Docker is installed. Log out and back in (or run: newgrp docker), then verify with:'
echo '  docker run --rm hello-world'
echo '  docker compose version'
echo 'Members of the docker group effectively have root-level access to this host.'
