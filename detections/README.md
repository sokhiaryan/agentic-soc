# detections/

Custom Wazuh rules and decoders, written (not just configured) as part of this project.

- `rules/` — custom rule XML files.
- `decoders/` — custom decoder XML files, where a built-in decoder isn't sufficient.
- `test-cases/` — a log sample and expected alert for each rule, so detections here are testable, not just present.

For every detection, document in this folder (or link from here to a `docs/detection-engineering/` write-up):

- Detection objective
- Data source
- Trigger condition
- Rule logic
- Known false positives
- MITRE ATT&CK mapping
- Severity
- Test procedure and expected result
