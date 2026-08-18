# docs/architecture/

Working architecture documentation — written to explain, not just illustrate.

Planned first artifact: `wazuh-architecture.drawio` / `wazuh-architecture.png`, with an accompanying explanation of each component:

- **Manager** — detection and management layer (rules, decoders, correlation, MITRE mapping).
- **Indexer** — storage/search layer.
- **Dashboard** — analyst interface.
- **Agent** — endpoint telemetry collection.

Later additions: the full pipeline diagram (telemetry → detection → API → automation → investigation → threat intel → verdict → human approval → response) and the agentic investigation flow (planner → tools → evidence → analysis).
