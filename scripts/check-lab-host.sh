#!/usr/bin/env bash
# Report whether this Linux host can run the complete Wazuh + n8n lab.
set -euo pipefail

required_cpu=4
# Wazuh documents these limits in decimal GB, not binary GiB.
required_ram_bytes=8000000000
required_disk_bytes=50000000000
failed=0

ram_bytes=$(awk '/MemTotal:/ {print $2 * 1024}' /proc/meminfo)
disk_bytes=$(df -B1 . | awk 'NR == 2 {print $4}')
cpu_count=$(nproc)
map_count=$(sysctl -n vm.max_map_count)

printf 'OS: %s\n' "$(. /etc/os-release && printf '%s' "$PRETTY_NAME")"
printf 'CPU cores: %s (minimum: %s)\n' "$cpu_count" "$required_cpu"
awk -v value="$ram_bytes" -v minimum="$required_ram_bytes" 'BEGIN { printf "RAM: %.2f GB (minimum: %.0f GB)\n", value / 1000000000, minimum / 1000000000 }'
awk -v value="$disk_bytes" -v minimum="$required_disk_bytes" 'BEGIN { printf "Free disk in current filesystem: %.2f GB (minimum: %.0f GB)\n", value / 1000000000, minimum / 1000000000 }'
printf 'vm.max_map_count: %s (minimum: 262144)\n' "$map_count"

if command -v docker >/dev/null 2>&1; then
  docker --version
  docker compose version
else
  echo 'Docker: not installed'
  failed=1
fi

(( cpu_count >= required_cpu )) || { echo 'FAIL: insufficient CPU.'; failed=1; }
(( ram_bytes >= required_ram_bytes )) || { echo 'FAIL: insufficient RAM for the Wazuh single-node stack.'; failed=1; }
(( disk_bytes >= required_disk_bytes )) || { echo 'FAIL: insufficient free disk.'; failed=1; }
(( map_count >= 262144 )) || { echo 'FAIL: vm.max_map_count must be raised before Wazuh starts.'; failed=1; }

if (( failed )); then
  echo 'Result: host is not ready for the complete lab.'
  exit 1
fi

echo 'Result: host meets the baseline for the complete lab.'
