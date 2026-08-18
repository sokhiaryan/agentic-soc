# prompts/

System prompts for the AI components, versioned like code because they are code.

- `security-analyst.md` — the analyst that reads an evidence bundle and returns a structured verdict conforming to `schemas/alert-verdict.schema.json`. No free-form "this looks malicious."
- `investigator.md` — the agentic investigator that plans which tools to call (`get_agent_details`, `get_recent_alerts`, `check_file_hash`, `check_ip_reputation`, `lookup_attack_technique`, etc.) before handing evidence to the analyst.

Changes to these prompts should be treated like changes to any other interface: note in the commit message what behavior changed and why, and re-run the scenarios in `tests/scenarios/` to check for regressions.
