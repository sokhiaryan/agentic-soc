# Day 1 Runbook — Foundation + Wazuh

Run this on the machine that will host the lab (native Linux, WSL2 on Windows with Docker Desktop, or a cloud VPS — anything Debian/Ubuntu-based with 4+ CPU cores, 8+ GB RAM, 50+ GB free disk). Do this on your own machine/terminal, not inside a chat tool — paste outputs back into `LAB-NOTE-001` and `LAB-NOTE-002` as you go.

## 0. Create the repo

```bash
git init agentic-soc && cd agentic-soc
# (or: unzip the scaffold you were given, then `cd agentic-soc && git init`)
git add README.md .gitignore LICENSE docs
git commit -m "chore: initialize security operations lab"
git add docs/ROADMAP.md
git commit -m "docs: define lab architecture and objectives"
```

## 1. Install prerequisites

```bash
# Docker Engine + Compose plugin (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER   # log out/in (or `newgrp docker`) to apply

sudo apt-get update && sudo apt-get install -y git curl jq
```
Install Postman separately (desktop app or `snap install postman`).

Log out and back in (or open a new shell) so the `docker` group membership takes effect, then verify:

```bash
docker version
docker compose version
uname -a
free -h
lsblk
df -h
git --version
```

Fill these results into `docs/lab-notes/LAB-NOTE-001-environment-baseline.md`, then:

```bash
git add docs/lab-notes/LAB-NOTE-001-environment-baseline.md
git commit -m "feat: provision docker environment"
```

## 2. Set the kernel parameter Wazuh's indexer needs

```bash
sudo sysctl -w vm.max_map_count=262144
# persist across reboots:
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```
(The Wazuh indexer, built on OpenSearch, creates many virtual memory areas and needs this raised above the Linux default of 65530.)

## 3. Deploy Wazuh single-node (Docker)

Deploy the **official** repo rather than a copied compose file:

```bash
git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.7
cd wazuh-docker/single-node/
```

From here, follow the official current instructions exactly (they include a certificate-generation step and the `docker compose up -d` command) — copy-paste directly from the doc page rather than from memory, since exact command syntax has changed between Wazuh versions:

- https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

Expect roughly this shape, but confirm against the page above before running:

```bash
# generate certs for inter-node TLS
docker compose -f generate-indexer-certs.yml run --rm generator

# start the stack
docker compose up -d

# watch it come up
docker compose ps
docker compose logs -f
```

Default exposed ports:

| Port | Service |
|---|---|
| 443 | Wazuh dashboard (HTTPS) |
| 55000 | Wazuh manager REST API |
| 9200 | Wazuh indexer API |
| 1514 / 1515 | Agent enrollment / event forwarding (TCP) |
| 514 | Syslog (UDP) |

Log into the dashboard at `https://<host>` — default is `admin` / the password set during cert generation (check the compose file / `.env` in `single-node/` for the exact variable, e.g. `INDEXER_PASSWORD` / `DASHBOARD_PASSWORD` — **change these from the repo defaults before this ever touches a real network**).

Once it's up:

```bash
cd ../..   # back to agentic-soc/
git add infrastructure/wazuh
git commit -m "feat: deploy wazuh single-node environment"
```

(Only commit your own compose overrides/config here, not the cloned `wazuh-docker` repo itself or the generated certs — both should stay out of git; see `.gitignore`.)

## 4. Understand the architecture before moving on

Read (or re-read) what each component does, then write it in your own words in `docs/architecture/wazuh-architecture.png`'s accompanying notes:

- **Manager** — detection/management layer: rules, decoders, correlation, MITRE mapping.
- **Indexer** — storage/search layer (OpenSearch-based).
- **Dashboard** — the analyst-facing UI.
- **Agent** — endpoint telemetry collector (next step).

```bash
git add docs/architecture
git commit -m "docs: document wazuh architecture"
```

## 5. Install the local agent and get first telemetry

Follow the Wazuh dashboard's "Add agent" wizard (Endpoint Security → Agents → Deploy new agent) — it generates the exact install command for your OS. On the same Ubuntu host (or a second VM), install it, start it, and confirm it shows "Active" in the dashboard.

Then generate some real events to see telemetry actually flow:

```bash
# a few harmless but loggable actions
sudo -i    # then exit immediately — generates a sudo/auth event
ssh localhost   # if sshd is running — generates an SSH auth event (Ctrl+C to cancel)
touch /etc/test-fim-file && sudo rm /etc/test-fim-file   # if FIM is watching /etc
```

In the dashboard, find the resulting alert(s), open one, and copy its raw JSON.

```bash
git add docs/wazuh docs/lab-notes
git commit -m "feat: validate endpoint telemetry"
```

## 6. Write LAB-NOTE-002 and the event anatomy doc

Use `docs/lab-notes/TEMPLATE.md` to write `LAB-NOTE-002-wazuh-deployment.md` (objective: understand the manager/indexer/dashboard split and confirm agent → manager telemetry flow).

Then create `docs/wazuh/event-anatomy.md`: paste one real alert JSON and annotate every field (`timestamp`, `agent.id/name/ip`, `rule.id/level/description`, `data.*`) in your own words.

```bash
git add docs/wazuh/event-anatomy.md docs/lab-notes
git commit -m "docs: analyze wazuh event schema"
```

## End of Day 1 checklist

- [ ] Repo initialized with Stage 0 scaffold
- [ ] Docker + Compose + Git + jq + Postman installed, versions recorded
- [ ] `vm.max_map_count` set
- [ ] Wazuh single-node stack deployed and reachable at `https://<host>`
- [ ] Default dashboard/indexer passwords changed from repo defaults
- [ ] Local agent installed and showing Active
- [ ] At least one real alert captured as raw JSON
- [ ] `LAB-NOTE-001` and `LAB-NOTE-002` written
- [ ] `docs/wazuh/event-anatomy.md` written
- [ ] Everything committed with the message sequence above

Next: Day 2 (Postman + the Wazuh API arc) — start with `POST /security/user/authenticate` against port 55000 and build out `docs/api/wazuh-api-notes.md` endpoint by endpoint.
