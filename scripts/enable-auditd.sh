#!/usr/bin/env bash
# Enable Linux audit telemetry and make the local Wazuh agent ingest it.
set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo 'Run as your normal sudo-capable user, not as root.' >&2
  exit 1
fi

. /etc/os-release
if [[ ${ID:-} != ubuntu ]]; then
  echo "This script supports Ubuntu only; detected: ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

if ! sudo test -f /var/ossec/etc/ossec.conf; then
  echo 'Wazuh agent configuration not found at /var/ossec/etc/ossec.conf.' >&2
  echo 'Deploy and start the Wazuh agent before enabling audit ingestion.' >&2
  exit 1
fi

sudo apt update
sudo apt install -y auditd audispd-plugins

# Audit execve calls by normal interactive users. The Wazuh default rules map this
# key to command-execution alerts. Keep this narrowly scoped for the lab.
sudo tee /etc/audit/rules.d/99-agentic-soc-exec.rules >/dev/null <<'EOF'
-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=-1 -k audit-wazuh-c
EOF
sudo augenrules --load
sudo systemctl enable --now auditd

if ! sudo grep -Fq '<location>/var/log/audit/audit.log</location>' /var/ossec/etc/ossec.conf; then
  sudo sed -i '/<\/ossec_config>/i\  <localfile>\n    <log_format>audit</log_format>\n    <location>/var/log/audit/audit.log</location>\n  </localfile>' /var/ossec/etc/ossec.conf
fi
sudo systemctl restart wazuh-agent

echo 'Auditd and Wazuh audit-log ingestion are enabled.'
echo 'Verify the rule and services with:'
echo '  sudo auditctl -l | grep audit-wazuh-c'
echo '  sudo systemctl --no-pager --full status auditd wazuh-agent'
