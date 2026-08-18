# Agentic SOC

An experimental security operations platform that combines Wazuh detection, REST API automation, n8n SOAR workflows, threat intelligence, and LLM-based investigation.

The project explores a simple question:

> Can an AI agent investigate a security alert by collecting additional evidence through security APIs, explain its reasoning, and recommend an appropriate response while keeping a human analyst in control?

This is not a chatbot bolted onto a SIEM. It's a small, complete SOC engineering platform that demonstrates the entire chain:

```
Telemetry → Detection → API → Automation → Investigation → Threat Intelligence → Analyst Decision → Human-approved Response → Documentation
```

## Architecture

```
                         SECURITY LAB
                              |
          +--------------------+--------------------+
          |                                         |
          v                                         v
    Ubuntu Endpoint                           Future Windows
    Wazuh Agent                               Endpoint / AD
          |                                         |
          +--------------------+--------------------+
                              |
                              v
                     +-----------------+
                     |  Wazuh Manager  |
                     |  Rules          |
                     |  Decoders       |
                     |  Correlation    |
                     |  MITRE ATT&CK   |
                     +--------+--------+
                              |
                              v
                     +-----------------+
                     |    Wazuh API    |
                     +--------+--------+
                              |
                              v
                     +-----------------+
                     |       n8n       |
                     |   SOAR Layer    |
                     +--------+--------+
                              |
                   +----------+----------+
                   v                     v
             Enrichment             AI Analyst
           (VirusTotal, etc.)           |
                   |                     |
                   +----------+----------+
                              v
                     +-----------------+
                     |  Investigation  |
                     |    & Verdict    |
                     +--------+--------+
                              |
                    +----------+----------+
                    v                     v
              Human Approval          Evidence
                    |                 / Report
                    v
                Response
```

See `docs/architecture/` for the annotated version of this diagram and `architecture/` for rendered exports (`.drawio` / `.png`).

## Capabilities (tracked as they're built — see `docs/ROADMAP.md`)

- [ ] Endpoint telemetry (Wazuh agent)
- [ ] SIEM detection (Wazuh manager, single-node Docker deployment)
- [ ] Custom detection rules + decoders
- [ ] REST API automation (Wazuh API, JWT auth, Postman collection)
- [ ] SOAR workflows (n8n)
- [ ] Threat intelligence enrichment (VirusTotal, IP/domain/hash reputation)
- [ ] MITRE ATT&CK mapping
- [ ] AI-assisted investigation (structured verdict schema)
- [ ] Evidence-before-opinion agentic investigation (tool-calling)
- [ ] File Integrity Monitoring flagship demo
- [ ] Human-in-the-loop response approval
- [ ] Incident report generation
- [ ] Attack simulation test scenarios
- [ ] Detection / automation / AI accuracy metrics

## Repository layout

```
agentic-soc/
├── docs/                     research-style documentation: lab notes, architecture, API notes, detection write-ups
├── infrastructure/           docker-compose and config for wazuh + n8n
├── postman/wazuh-api/        hand-built Postman collection for the Wazuh REST API
├── workflows/                exported n8n workflow JSON
├── detections/               custom Wazuh rules, decoders, and their test cases
├── schemas/                  JSON schemas — normalized alert, investigation, verdict
├── prompts/                  system prompts for the AI analyst / investigator
├── integrations/             threat intel and MITRE ATT&CK enrichment code
├── scripts/                  supporting Python/bash scripts
├── tests/                    attack simulation scenarios and expected results
├── incidents/                generated incident reports (one folder per incident)
├── screenshots/              evidence captures referenced from docs
├── architecture/             rendered architecture diagrams (.drawio/.png)
└── LICENSE
```

Why the structure matters: this repo is meant to read as a security engineering project, not a workflow dump. Every stage below produces something that lands in one of these folders, with documentation that explains *why*, not just *what*.

## Roadmap

The build is staged deliberately — see `docs/ROADMAP.md` for the full breakdown and `docs/lab-notes/` for the day-by-day log.

| Stage | Demonstrates |
|---|---|
| Foundation | Linux, Docker, networking, deployment |
| Detection | SIEM, telemetry, Wazuh, detection engineering |
| Automation | REST APIs, JSON, Postman, n8n |
| Intelligence | Threat intel, MITRE ATT&CK, enrichment |
| AI/SOC | LLMs, structured reasoning, agentic workflows |
| Engineering | Testing, observability, security, documentation |

## Documentation philosophy

Every experiment gets a lab note (`docs/lab-notes/`) answering: Objective, Hypothesis, Environment, Procedure, Observation, Evidence, Result, What I learned, Problems encountered, Security implications, Next experiment.

Failures are documented, not deleted. A debugging session that ends in "root cause: JWT wasn't propagated through the n8n HTTP node" is worth more here than a changelog that pretends everything worked the first time.

## License

MIT — see `LICENSE`.
