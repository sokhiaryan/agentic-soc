# schemas/

JSON Schema contracts between the pipeline stages. Defining these early (before the AI analyst is built) is what turns "an LLM that talks to an API" into an actual engineered system with typed boundaries.

- `normalized-alert.schema.json` — the shape of a Wazuh alert after n8n normalization, before enrichment.
- `investigation.schema.json` — the evidence bundle collected during investigation (agent info, related alerts, process/file context, threat intel results).
- `alert-verdict.schema.json` — the AI analyst's structured output: verdict, confidence, severity, ATT&CK mapping, evidence, reasoning summary, recommended actions, `requires_human_approval`.
