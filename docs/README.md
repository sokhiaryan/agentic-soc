# docs/

Research and engineering documentation for the project — not user-facing tutorials, notes written to think clearly and to leave evidence of understanding.

- `ROADMAP.md` — the staged build plan and definition of v1.0 success.
- `lab-notes/` — one file per experiment, using `TEMPLATE.md`. This is the primary evidence trail: objective, hypothesis, procedure, observation, result, lessons, problems, security implications.
- `architecture/` — working diagrams and explanations of how components fit together (Wazuh internals, the full pipeline, investigation flow). Rendered/final diagrams also get exported to the top-level `architecture/` folder for the README.
- `wazuh/` — Wazuh-specific deep dives (e.g. `event-anatomy.md`).
- `api/` — the Wazuh REST API notebook: one entry per endpoint (method, auth, params, request/response, failure modes, n8n equivalent).
- `n8n/` — workflow design notes and screenshots of the SOAR layer.
- `detection-engineering/` — methodology notes that sit alongside the rules themselves in `detections/`.
- `ai/` — system prompt design, schema design, agentic tool design, and evaluation notes for the AI analyst.
- `threat-intelligence/` — enrichment source notes (VirusTotal, MITRE ATT&CK).
- `incidents/` — narrative write-ups that complement the structured incident folders in the top-level `incidents/`.
