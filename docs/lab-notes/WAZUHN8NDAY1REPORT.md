# Wazuh \+ n8n SOC Lab — Day 1 Deployment and Telemetry Validation

**Date:** 2026-08-18 **Host:** Ubuntu 24.04 LTS (arm64), local VM/lab environment, user `sokhi` **Repository:** `agentic-soc` (`~/Desktop/agentic-soc`)

---

## 1\. Executive summary

On Day 1, the core infrastructure of the Wazuh \+ n8n SOC lab was deployed and validated end to end. Docker Engine and Docker Compose were installed and confirmed working. The official Wazuh single-node Docker stack (version 4.14.7 — Manager, Indexer, Dashboard) was deployed, came up healthy, and was reached through the browser with an authenticated login. A local Ubuntu Wazuh agent (v4.14.7) was installed, enrolled against the manager, and confirmed **Active** in the dashboard. `auditd` was installed and enabled with a Wazuh-specific audit rule watching process execution. n8n was deployed as a fourth container, deliberately bound to `127.0.0.1:5678` only, and its owner account was created, reaching the workflow builder home screen.

What remains open going into the next session: confirming that `auditd`\-sourced telemetry actually surfaces as alerts inside the Wazuh dashboard, installing PowerShell Core, and running a single reviewed Atomic Red Team test to observe the resulting detection — none of which were performed today.

## 2\. Lab objective

Stand up the baseline Wazuh \+ n8n infrastructure on a local Ubuntu VM and validate the health of every component individually — Docker, the Wazuh Manager/Indexer/Dashboard, the local agent, and n8n — before building any detection content, enrichment, or automation on top of it. This follows the project's staged approach: infrastructure and telemetry fundamentals first, automation and analysis layered on afterward.

## 3\. Environment and resource baseline

| Item | Value |
| :---- | :---- |
| OS | Ubuntu 24.04.4 LTS (as reported by the enrolled Wazuh agent) |
| Architecture | arm64 / aarch64 |
| Hostname | `ubuntu` |
| User | `sokhi` |
| Docker Engine version | \[not captured\] |
| Docker Compose version | \[not captured\] |
| CPU cores | 8 |
| RAM | \[not captured\] |
| Disk free space | \[not captured\] |

`docker version`, `docker compose version`, and `./scripts/check-lab-host.sh` were executed as part of the Day 1 session, but their full console output was not visible in the captured screenshots, so exact tool versions and hardware headroom are not recorded here. These should be captured explicitly in a future lab note (e.g. `docs/lab-notes/`) if the numbers are needed for the record.

## 4\. Architecture deployed

### Docker

Installed via `./scripts/install-docker-ubuntu.sh`. The user was added to the `docker` group and the membership applied in-session with `newgrp docker`. Verified functional with `docker run --rm hello-world`, which pulled the `arm64v8` image and returned the standard "Hello from Docker\!" confirmation message.

### Wazuh Manager

Deployed as container `single-node-wazuh.manager-1` from `wazuh/wazuh-manager:4.14.7`, entrypoint `/init`. Ports published: `1514-1515/tcp`, `514/udp`, `55000/tcp` (REST API), `1516/tcp`. Confirmed `Up` via `docker compose ps`.

### Wazuh Indexer

Deployed as container `single-node-wazuh.indexer-1` from `wazuh/wazuh-indexer:4.14.7`. Port published: `9200/tcp`. Confirmed `Up` via `docker compose ps`.

### Wazuh Dashboard

Deployed as container `single-node-wazuh.dashboard-1` from `wazuh/wazuh-dashboard:4.14.7`. Port published: `443/tcp` (mapped to internal `5601`). Reached at `https://localhost`, logged in as `admin`. Dashboard logs confirm the OpenSearch Dashboards keystore was created and the Wazuh app was already configured on startup.

### Ubuntu Wazuh agent

Installed from `wazuh-agent_4.14.7-1_arm64.deb`, downloaded directly from `packages.wazuh.com`, and installed via:

sudo WAZUH\_MANAGER='127.0.0.1' WAZUH\_AGENT\_NAME='ubuntu-agent' dpkg \-i ./wazuh-agent\_4.14.7-1\_arm64.deb

Enabled and started via `systemctl enable wazuh-agent` / `systemctl start wazuh-agent`. Registered in the manager as agent **ID 001**, name `ubuntu-agent`, and confirmed **Active** in the Endpoints view, running its full process set (`wazuh-execd`, `wazuh-agentd`, `wazuh-syscheckd`, `wazuh-logcollector`, `wazuh-modulesd`).

### n8n

Deployed via `./scripts/bootstrap-n8n.sh`, using `docker compose -f infrastructure/n8n/compose.yaml`. Container `n8n-n8n-1` (image `n8nio/n8n:latest`) started with a persistent volume (`n8n_n8n_data`) and a freshly generated `.env` encryption key. The bootstrap script deliberately publishes the port as `127.0.0.1:5678->5678/tcp` — loopback-only — and prints an explicit warning against exposing port 5678 directly. The owner account was created (email `sokhiaryan@icloud.com`, name Aryan Sokhi), and the session reached the "Let's build your first automation" workflow home screen.

## 5\. Implementation timeline

| Time (local) | Action |
| :---- | :---- |
| 22:34 | `install-docker-ubuntu.sh` run; `check-lab-host.sh` triggers `apt-get update` |
| 22:35 | Docker group applied; `docker run --rm hello-world` succeeds |
| 22:39 | Wazuh certificate generation begins; `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard` 4.14.7 images start pulling |
| 22:47 | Wazuh stack fully up (62/63 steps); all 3 containers started; dashboard reported at `https://localhost` |
| 22:49 | `docker compose ps` confirms all 3 containers `Up`; dashboard container logs streaming normally |
| 22:50 | Wazuh dashboard login page loading in browser |
| 22:54 | Login page fully rendered; `admin` credentials entered |
| 23:01–23:02 | "Deploy new agent" wizard: Linux DEB aarch64 package, server address `127.0.0.1`, agent name `ubuntu-agent` |
| 23:03 | Agent package downloaded and installed via `dpkg`; `wazuh-agent` service enabled and started |
| 23:05 | Dashboard Endpoints view confirms `ubuntu-agent` (ID 001\) registered and Active |
| 23:24–23:28 | `auditd` installed/enabled with rule `key=audit-wazuh-c` (execve, uid≥1000); `auditd` and `wazuh-agent` services both confirmed `active (running)` |
| 23:34 | `bootstrap-n8n.sh` run; n8n container up, bound to `127.0.0.1:5678` only |
| 23:38 | n8n owner account created |
| 23:39 | n8n Workflows home reached |

## 6\. Evidence and screenshots

Save each corresponding screenshot into `screenshots/` under the filename listed, so the links below resolve once this report is committed to the repository.

**Docker and host bootstrap** Terminal running install-docker-ubuntu.sh, check-lab-host.sh, and apt-get update output Shows `install-docker-ubuntu.sh` and `check-lab-host.sh` being invoked from `~/Desktop/agentic-soc`, and the `apt-get update` output triggered by the host-check script (package lists refreshed, `ca-certificates` already current). Proves the bootstrap scripts run from the correct working directory.

docker run --rm hello-world output confirming Docker Engine works Shows the full "Hello from Docker\!" message after pulling the `arm64v8` `hello-world` image. Proves Docker Engine is installed and functional, and that the `docker` group membership took effect after `newgrp docker`.

**Wazuh stack deployment** Wazuh certificate generation and image pull in progress Shows the `wazuh-certs-generator` container running `wazuh-certs-tool.sh`, generating the root, admin, indexer, filebeat, and dashboard certificates, followed by the three Wazuh 4.14.7 images beginning to pull. Also shows a non-fatal `find: command not found` error at line 636 of the script (see Section 10).

Wazuh single-node stack fully started Shows Docker Compose completing all 62/63 steps: three images pulled, all named volumes created, and the indexer, manager, and dashboard containers started. Confirms the deployment path (`.../agentic-soc/infrastructure/wazuh/wazuh-docker/single-node`) and prints the dashboard URL (`https://localhost`) and manager API hostname (`https://wazuh-manager:55000`).

docker compose ps output and dashboard container logs Shows all three containers (`dashboard`, `indexer`, `manager`) in the `Up` state with their published ports, and the dashboard container's own logs streaming (OpenSearch Dashboards keystore created, plugin initialization). Confirms the stack stayed healthy after startup, not just immediately after `up`.

Wazuh dashboard login page loading Shows the browser reaching `https://localhost/app/login`, confirming port 443 is reachable from the host.

Wazuh dashboard login page with admin credentials entered Shows the login form filled with the `admin` username immediately before submitting. (Login success is confirmed indirectly in the next two screenshots, which show authenticated pages.)

**Agent deployment** Deploy new agent wizard — Linux DEB aarch64 selected Shows the dashboard's "Deploy new agent" wizard with the Linux DEB aarch64 package selected, matching the host's arm64 architecture.

Deploy new agent wizard — server address and agent name Shows the wizard's server address field set to `127.0.0.1` and the agent name set to `ubuntu-agent`.

wazuh-agent package download, install, and service start Shows the agent `.deb` package downloaded via `wget`, installed via `dpkg -i` with `WAZUH_MANAGER=127.0.0.1` and `WAZUH_AGENT_NAME=ubuntu-agent`, and the systemd service enabled and started.

Wazuh Endpoints view showing ubuntu-agent Active Shows the Endpoints summary: 1 agent, status Active, OS Ubuntu 24.04.4 LTS, version v4.14.7, IP `127.0.0.1`, group `default`. Confirms successful enrollment and heartbeat.

**auditd enablement** auditd service status — active and running Shows `auditd.service` active (running) since 23:24:47, with the Wazuh-specific audit rule `-a always,exit -F arch=b64 -S execve -F auid>=1000 -F auid!=-1 -F key=audit-wazuh-c` confirmed loaded via `auditctl -l`.

wazuh-agent.service status detail after auditd enablement Shows `wazuh-agent.service` active (running) with its full child process tree (`wazuh-execd`, `wazuh-agentd`, `wazuh-syscheckd`, `wazuh-logcollector`, `wazuh-modulesd`) and the systemd journal entries recording a clean startup sequence.

**n8n deployment** bootstrap-n8n.sh output — n8n container started, bound to localhost Shows `bootstrap-n8n.sh` generating a new `.env` encryption key, pulling `n8nio/n8n:latest`, starting container `n8n-n8n-1`, and the explicit console warning that n8n is reachable only at `127.0.0.1:5678` and should not be exposed directly.

n8n owner account setup form Shows the n8n "Set up owner account" form completed with email `sokhiaryan@icloud.com`, first name Aryan, last name Sokhi.

n8n Workflows home screen Shows the authenticated n8n home screen ("Let's build your first automation"), confirming the owner account setup completed successfully and the service is fully reachable at `http://127.0.0.1:5678`.

## 7\. Repository engineering work

**Added scripts and n8n configuration.** The lab bootstrap logic now lives in versioned scripts rather than ad hoc commands: `scripts/install-docker-ubuntu.sh`, `scripts/check-lab-host.sh`, and `scripts/bootstrap-n8n.sh` were exercised directly in today's session. Per the working plan, the repository also includes scripts for `auditd` enablement (exercised today), PowerShell installation, and a guarded Atomic Red Team preparation/execution flow (both planned for the next session — see Section 11). n8n's Docker Compose configuration (`infrastructure/n8n/compose.yaml`) adds persistent storage, an isolated Docker network (`soc-net`), and a private `.env` encryption-key file that is excluded from version control.

**Simplified project structure.** The initial planning scaffold included placeholder directories for AI/agentic components, threat-intelligence integrations, incident reports, prompts, schemas, and generic integrations — none of which had real content yet. These were removed so the repository reflects only what has actually been built (infrastructure, detection-engineering fundamentals, and lab documentation), rather than describing future ambitions as if they already existed.

**Git commit.** Today's infrastructure work was committed as:

c749bee feat: add auditd, atomic testing, and n8n lab setup

## 8\. Security decisions and limitations

**Local/private service exposure.** n8n is explicitly bound to `127.0.0.1:5678` only — confirmed both by the port mapping in `docker compose ps` and by the bootstrap script's own printed warning against exposing it directly. The Wazuh dashboard and manager API are likewise only confirmed reachable via `localhost` in this session. Keeping every service on loopback-only bindings is the right default for a personal single-user lab; any future remote access should go through an SSH tunnel or a reverse proxy with authentication, not a direct port exposure.

**Docker group privilege implications.** The lab user (`sokhi`) was added to the `docker` group to run Docker without `sudo`. This is a standard but meaningful tradeoff: group membership in `docker` is effectively root-equivalent on the host, since any container can bind-mount the host filesystem. Acceptable for a single-user lab VM; worth remembering before this environment is ever shared or exposed.

**Secrets excluded from Git.** The n8n `.env` file generated during bootstrap contains an encryption key and is explicitly called out as private and requiring backup outside the repository. The same handling applies to Wazuh's generated certificates and any dashboard/API credentials — these should stay out of version control, consistent with the repository's `.gitignore`.

**Atomic tests require explicit review and approval.** The Atomic Red Team tooling referenced in the repository is described as "guarded" by design: it prepares and previews a test before execution, requiring a deliberate human decision to run it against the lab. No Atomic test has been executed yet (see Section 9).

## 9\. Validation results

| Component | Status | Evidence |
| :---- | :---- | :---- |
| Docker Engine | Working | Screenshot 02 (`hello-world` success) |
| Wazuh Manager / Indexer / Dashboard containers | Up, healthy | Screenshots 04, 05 |
| Wazuh dashboard login | Reachable; authenticated session confirmed indirectly by later authenticated pages | Screenshots 06, 07, 08 |
| Wazuh agent (`ubuntu-agent`) | Active, enrolled | Screenshot 11 |
| `auditd` service | Active (running), Wazuh rule loaded | Screenshots 12, 13 |
| `wazuh-agent` service | Active (running), full process set | Screenshot 13 |
| n8n | Up, owner account created, workflow home reached | Screenshots 14, 15, 16 |
| `auditd`\-sourced telemetry visible as Wazuh alerts | Not validated | \[not captured\] |
| PowerShell installation | Not performed | \[not captured\] |
| Atomic Red Team execution | Not performed | \[not captured\] |

## 10\. Problems encountered and resolutions

**Initial Wazuh disk-capacity guard.** The lab bootstrap scripts include a disk-capacity guard intended to verify sufficient free space (Wazuh's single-node stack recommends 50 GB+) before deployment proceeds. This guard reportedly blocked the first deployment attempt; space was freed and a subsequent run passed. The exact guard output and remediation steps were not captured in the provided screenshots.

**Git author identity initially missing before commit.** The local repository reportedly lacked a configured `user.name`/`user.email` before the first commit attempt. This was resolved by setting the identity for the repository prior to committing. The exact error message was not captured in the provided screenshots.

**`find: command not found` during certificate generation.** The `wazuh-certs-tool.sh` script (invoked by the certs-generator container) printed `/wazuh-certs-tool.sh: line 636: find: command not found` while generating certificates. This did not block the deployment — certificate generation continued and the full stack came up successfully afterward, as shown in the subsequent screenshot. Root cause (e.g. a missing `findutils` binary inside that specific container image) was not investigated further today.

## 11\. Next session plan

1. Confirm that `auditd`\-sourced telemetry (execve events tagged `key=audit-wazuh-c`, already enabled and running as of Day 1\) appears as alerts in the Wazuh dashboard.  
2. Install PowerShell Core on the Ubuntu host.  
3. Preview one reviewed Atomic Red Team test case (guarded — requires explicit human approval before execution).  
4. Run that single approved Atomic test and observe the resulting Wazuh alert(s).  
5. Begin a basic n8n workflow that authenticates against the Wazuh REST API (port 55000).

---

## Skills demonstrated

Linux administration, Docker Compose, SIEM deployment, endpoint monitoring, Git hygiene, secure configuration handling, and SOC lab documentation.  
