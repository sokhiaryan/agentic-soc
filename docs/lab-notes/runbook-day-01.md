# Lab Runbook — Agent Telemetry, Atomic Test, and n8n

This runbook assumes the Wazuh Docker stack is healthy and an Ubuntu Wazuh agent has already been deployed.

## 1. Confirm the agent is active

In Wazuh Dashboard, open **Endpoint Security → Agents**. Confirm the Ubuntu endpoint is **Active** before continuing.

On the endpoint:

```bash
sudo systemctl --no-pager --full status wazuh-agent
sudo tail -n 50 /var/ossec/logs/ossec.log
```

Start a new note named `docs/lab-notes/LAB-NOTE-003-agent-audit-atomic.md` using `TEMPLATE.md`. Record the host name, Wazuh agent version, manager address, and this status output.

## 2. Enable auditd telemetry

This installs `auditd`, enables a narrowly scoped audit rule for command execution by normal users, configures the Wazuh agent to ingest `/var/log/audit/audit.log`, and restarts the agent.

```bash
cd /home/sokhi/Desktop/agentic-soc
./scripts/enable-auditd.sh
sudo auditctl -l | grep audit-wazuh-c
sudo systemctl --no-pager --full status auditd wazuh-agent
```

Wait one or two minutes, then search Wazuh Threat Hunting for `audit-wazuh-c` or the endpoint agent name. Paste the audit-rule output and a small matching alert JSON excerpt into LAB-NOTE-003.

## 3. Start n8n in a second terminal

n8n can install while audit telemetry is flowing. It remains bound to localhost.

```bash
cd /home/sokhi/Desktop/agentic-soc
./scripts/bootstrap-n8n.sh
docker compose -f infrastructure/n8n/compose.yaml ps
```

Open `http://127.0.0.1:5678` and create the owner account. Record the n8n image/version and service status in LAB-NOTE-003. Do not commit `infrastructure/n8n/.env`.

## 4. Install PowerShell and prepare Atomic Red Team

```bash
cd /home/sokhi/Desktop/agentic-soc
./scripts/install-powershell-ubuntu.sh
pwsh -NoLogo -File tests/atomic/prepare-atomic-red-team.ps1
```

The preparation script installs the PowerShell execution module for the current user and downloads only the Atomic test-definition tree. It does not execute any test.

## 5. Preview, then run one reviewed Atomic test

Start with Unix Shell (`T1059.004`) test 8, the small command-line-script test that prints five messages and does not download content or require elevation. The first command is preview-only. Read the displayed commands and dependencies before running anything.

```bash
cd /home/sokhi/Desktop/agentic-soc
pwsh -NoLogo -File tests/atomic/run-atomic-test.ps1 -Technique T1059.004 -TestNumber 8
```

If the preview is acceptable for this private lab, execute it explicitly:

```bash
ATOMIC_LAB_APPROVED=YES pwsh -NoLogo -File tests/atomic/run-atomic-test.ps1 -Technique T1059.004 -TestNumber 8 -Execute
```

Search the Wazuh dashboard for the endpoint name and `audit-wazuh-c`. Capture the atomic test command, timestamp, Wazuh rule ID/level, and a short alert JSON excerpt in LAB-NOTE-003. Run the test cleanup only if the preview documents cleanup behavior:

```bash
ATOMIC_LAB_APPROVED=YES pwsh -NoLogo -File tests/atomic/run-atomic-test.ps1 -Technique T1059.004 -TestNumber 8 -Execute -Cleanup
```

## 6. Commit today's reproducible work

```bash
cd /home/sokhi/Desktop/agentic-soc
git add README.md .gitignore docs infrastructure/n8n scripts tests/atomic
git commit -m "feat: add auditd, atomic testing, and n8n lab setup"
```
