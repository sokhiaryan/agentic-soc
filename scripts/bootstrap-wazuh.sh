#!/usr/bin/env bash
# Deploy the official pinned Wazuh single-node stack and attach it to soc-net.
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
wazuh_root="$repo_root/infrastructure/wazuh/wazuh-docker"
wazuh_dir="$wazuh_root/single-node"
wazuh_version="v4.14.7"

command -v docker >/dev/null || { echo 'Docker is not installed.' >&2; exit 1; }
docker compose version >/dev/null

ram_bytes=$(awk '/MemTotal:/ {print $2 * 1024}' /proc/meminfo)
disk_bytes=$(df -B1 "$repo_root" | awk 'NR == 2 {print $4}')
if (( ram_bytes < 8000000000 )) && [[ ${ALLOW_UNDERSIZED_HOST:-0} != 1 ]]; then
  echo 'Refusing to start Wazuh: this host has less than 8 GB RAM.' >&2
  echo 'Use a VM/cloud host with 8+ GiB RAM. To override for an intentionally unstable experiment: ALLOW_UNDERSIZED_HOST=1 ./scripts/bootstrap-wazuh.sh' >&2
  exit 1
fi
if (( disk_bytes < 50000000000 )) && [[ ${ALLOW_UNDERSIZED_DISK:-0} != 1 ]]; then
  echo 'Refusing to start Wazuh: the filesystem containing this repository has less than 50 GB free.' >&2
  echo 'For a short-lived learning lab, explicitly override this check with:' >&2
  echo '  ALLOW_UNDERSIZED_DISK=1 ./scripts/bootstrap-wazuh.sh' >&2
  echo 'For sustained use, expand the lab disk before deploying the stack.' >&2
  exit 1
fi
if (( disk_bytes < 50000000000 )); then
  echo "WARNING: continuing below Wazuh's 50 GB disk recommendation. Monitor disk usage and do not retain unnecessary index data." >&2
fi

sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-wazuh.conf >/dev/null

if [[ ! -d $wazuh_root/.git ]]; then
  mkdir -p "$(dirname "$wazuh_root")"
  git clone --branch "$wazuh_version" --depth 1 https://github.com/wazuh/wazuh-docker.git "$wazuh_root"
fi

docker network inspect soc-net >/dev/null 2>&1 || docker network create soc-net >/dev/null
cd "$wazuh_dir"
if [[ ! -d config/wazuh_indexer_ssl_certs ]]; then
  docker compose -f generate-indexer-certs.yml run --rm generator
fi
docker compose up -d

for service in wazuh.manager wazuh.indexer wazuh.dashboard; do
  container_id=$(docker compose ps -q "$service")
  if [[ -z $container_id ]]; then
    echo "Wazuh service did not start: $service" >&2
    exit 1
  fi
  container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's#^/##')
  if ! docker network inspect soc-net --format '{{range .Containers}}{{.Name}} {{end}}' | grep -Fq "$container_name"; then
    docker network connect --alias "${service//./-}" soc-net "$container_id"
  fi
done

echo 'Wazuh is starting. Watch status with:'
echo "  cd $wazuh_dir && docker compose ps && docker compose logs -f"
echo 'Dashboard: https://localhost  |  n8n-to-manager API hostname: https://wazuh-manager:55000'
