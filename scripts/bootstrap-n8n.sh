#!/usr/bin/env bash
# Start the local-only n8n service on the shared SOC Docker network.
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
n8n_dir="$repo_root/infrastructure/n8n"

command -v docker >/dev/null || { echo 'Docker is not installed.' >&2; exit 1; }
docker compose version >/dev/null

if [[ ! -f $n8n_dir/.env ]]; then
  cp "$n8n_dir/.env.example" "$n8n_dir/.env"
  secret=$(openssl rand -hex 32)
  sed -i "s/replace-with-a-random-64-hex-character-secret/$secret/" "$n8n_dir/.env"
  echo "Created $n8n_dir/.env with a new encryption key. Keep it private and backed up."
fi

docker network inspect soc-net >/dev/null 2>&1 || docker network create soc-net >/dev/null
cd "$n8n_dir"
docker compose up -d
docker compose ps
echo 'n8n is available only from this host at: http://127.0.0.1:5678'
echo 'For remote access, use an SSH tunnel or put n8n behind an HTTPS reverse proxy; do not expose port 5678 directly.'
