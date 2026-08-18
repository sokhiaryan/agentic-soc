# Roadmap

This project is built in stages on purpose. Each stage produces artifacts that land in specific folders and gets at least one lab note. The AI/agentic pieces (Stage 6 onward) are deliberately late — the credibility of this project rests on understanding the telemetry and detection layer well enough to build an investigation system on top of real evidence, not on wiring an LLM to an API as fast as possible.

## Stage 0 — Lab, not application
Repository structure, documentation scaffolding, `.gitignore`, `LICENSE`, first lab note.
**Status: done (this session).**

## Stage 1 — Infrastructure
Docker Engine, Docker Compose, Git, curl, jq, Postman installed and versions recorded. First commits establish a reproducible baseline (`docker version`, `uname -a`, `free -h`, `lsblk` captured as evidence).

## Stage 2 — Wazuh
Deploy the official Wazuh single-node Docker stack (manager, indexer, dashboard). Document the architecture (`docs/architecture/wazuh-architecture.*`) and what each component does.

## Stage 3 — Become dangerous with Wazuh before touching AI
Install the local agent, generate real telemetry (auth, sudo, processes, SSH, file changes, network), and write `docs/wazuh/event-anatomy.md` annotating a real event field by field. Then write custom detection rules (`detections/rules/`) with objective, data source, trigger, logic, false positives, MITRE mapping, severity, and test procedure documented for each.

## Stage 4 — The API arc
Hand-built Postman collection (`postman/wazuh-api/`) covering authentication, manager, agents, rules, security events, syscheck. Progression: Dashboard → API call → Postman → curl → Python → n8n, each step documented in `docs/api/wazuh-api-notes.md`.

## Stage 5 — n8n as SOAR layer
Start with a trivial workflow (auth → get agents → get events → normalize → output) before building the real alert pipeline (webhook → normalize → enrichment → AI analyst → decision). "Evidence before opinion" is the core design principle from here on.

## Stage 6 — AI analyst, properly
The model returns a structured verdict object (`schemas/alert-verdict.schema.json`), not prose. System prompt lives in `prompts/security-analyst.md`. Then it becomes agentic: the model is given tools (`get_agent_details`, `get_recent_alerts`, `get_related_events`, `check_file_hash`, `check_ip_reputation`, `lookup_attack_technique`) and decides what evidence to pull before reaching a verdict.

## Stage 7 — Threat intelligence
VirusTotal for hash/IP/domain reputation. Three solid integrations, not fifteen half-working ones.

## Stage 8 — File Integrity Monitoring
Flagship demo: file modified → Wazuh FIM alert → n8n → hash + context → VirusTotal → AI agent → investigation → human approval.

## Stage 9 — Human-in-the-loop response
The AI recommends (e.g. `ISOLATE_ENDPOINT`) with reason, confidence, and evidence; a human approves or closes. Then: the incident report generator (`incidents/<date>-<n>/{alert,evidence,investigation}.json` + `report.md`).

## Stage 10 — Attack simulation & metrics
Controlled scenarios in `tests/scenarios/`, each mapped to an ATT&CK technique with expected telemetry → rule → alert → verdict → response. Then measure it: detection rate, false positive rate, time to triage/enrichment/verdict, AI verdict accuracy — even a small N (e.g. 20 controlled test cases) beats an unquantified claim.

## Definition of v1.0 success

Given a controlled security event, the system detects it, retrieves relevant evidence, enriches the event with external intelligence, maps it to MITRE ATT&CK, asks an AI investigator to analyze the evidence, produces a structured verdict with confidence and reasoning, records the investigation, and requires human approval before taking response action — end to end.
