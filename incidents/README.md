# incidents/

Generated incident folders, one per investigated alert, named `YYYY-MM-DD-NNN/`:

```
incidents/2026-08-18-001/
├── alert.json          the raw/normalized Wazuh alert
├── evidence.json        everything the agentic investigator collected
├── investigation.json   intermediate reasoning / tool calls
└── report.md            human-readable report: Summary, Affected Host, Detection,
                          Timeline, Evidence, Threat Intelligence, MITRE ATT&CK
                          Mapping, AI Assessment, Analyst Decision, Response,
                          Lessons Learned
```

`raw/` subfolders (if present) are gitignored — keep only sanitized, shareable evidence in version control.
