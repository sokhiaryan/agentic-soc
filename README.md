# Agentic SOC Lab
+
+A small, evidence-driven Wazuh and n8n security lab running on Ubuntu and Docker.
+
+## What this repository contains
+
+- `infrastructure/` — n8n Compose configuration and the ignored upstream Wazuh Docker checkout.
+- `scripts/` — repeatable host, Docker, Wazuh, n8n, auditd, and PowerShell setup helpers.
+- `tests/atomic/` — guarded PowerShell helpers for previewing and running Atomic Red Team tests.
+- `workflows/` — exported n8n workflows.
+- `detections/` — custom Wazuh rules, decoders, and test cases.
+- `postman/wazuh-api/` — Wazuh API requests and a safe environment template.
+- `docs/lab-notes/` — one dated note per lab session, with commands, observations, and evidence.
+
+## Lab flow
+
+1. Provision Docker and deploy the Wazuh single-node stack.
+2. Enroll an endpoint, enable auditd telemetry, and verify real events in Wazuh.
+3. Use a reviewed Atomic Red Team test to validate detections.
+4. Deploy n8n and automate a small Wazuh API workflow.
+
+## Safety
+
+This is a private lab. Keep Wazuh and n8n off the public internet, retain secrets only in ignored `.env` files, and review every Atomic Red Team test before executing it. Atomic test execution requires an explicit approval environment variable.
+
+## Documentation
+
+Create a new Markdown file in `docs/lab-notes/` for every work session. Use [the template](docs/lab-notes/TEMPLATE.md), include the raw command output or a focused screenshot as evidence, and commit the note with the configuration change it describes.
+
