# tests/

Controlled attack scenarios that make this a testable security system rather than a demo that only works once.

- `scenarios/` — one file per scenario (e.g. `suspicious-command.md`, `authentication-anomaly.md`, `file-modification.md`), each mapping: ATT&CK technique → attack simulation → expected telemetry → expected Wazuh rule → expected alert → expected AI verdict → expected response.
- `expected-results/` — the recorded expected output for each scenario, used to compute the accuracy/metrics numbers in the root README.
