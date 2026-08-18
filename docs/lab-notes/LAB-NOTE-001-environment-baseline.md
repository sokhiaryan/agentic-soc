# LAB-NOTE-001: Establishing a reproducible lab baseline

**Date:** 2026-08-18
**Stage:** Foundation
**Author:** Rajrishi

## Objective
Establish and record a known-good baseline environment (OS, Docker, Compose, Git) before deploying any security tooling, so the rest of the project is reproducible and any later problem can be traced back to a documented starting state.

## Hypothesis
A single host with Docker Engine + Docker Compose v2, at least 4 CPU cores, 8 GB RAM, and 50 GB free disk is sufficient to run the Wazuh single-node stack (manager + indexer + dashboard) alongside n8n. (Wazuh's own single-node Docker requirements: minimum 4 CPU cores, 8 GB RAM, 50 GB disk — see `docs/wazuh/README.md` and the official docs link in `docs/ROADMAP.md`.)

## Environment
_Fill in after running the commands below:_

- OS / distro:
- Kernel (`uname -a`):
- Architecture:
- CPU cores:
- RAM (`free -h`):
- Disk (`lsblk` / `df -h`):
- Docker version:
- Docker Compose version:
- Git version:

## Procedure
```bash
docker version
docker compose version
uname -a
free -h
lsblk
df -h
git --version
```
Capture the output of each command as evidence (paste into this note and/or save a screenshot to `screenshots/`).

## Observation
_Paste raw command output here._

## Evidence
- `screenshots/2026-08-18-environment-baseline.png` (or equivalent)
- Raw command output above

## Result
_State plainly: did the host meet Wazuh's minimum requirements? Any gaps (e.g. vm.max_map_count not yet set)?_

## What I learned
_e.g. anything surprising about resource headroom, virtualization overhead if running in a VM, etc._

## Problems encountered
_Document anything that didn't work cleanly — Docker not installed, permission errors (`docker.sock` group membership), insufficient RAM, etc. — and how it was resolved._

## Security implications
Running Docker typically means members of the `docker` group have root-equivalent access to the host. Note this now — it matters later when this lab starts running exposed services (Wazuh dashboard on 443, API on 55000, n8n webhooks) and when deciding whether this lab lives on an internet-facing host or an isolated one.

## Next experiment
LAB-NOTE-002: Deploy the Wazuh single-node Docker stack and document the manager/indexer/dashboard architecture.
