# postman/wazuh-api/

A hand-built Postman collection for the Wazuh REST API (manager default port 55000), organized to mirror the learning progression documented in `docs/api/wazuh-api-notes.md`:

```
01-authentication      POST /security/user/authenticate (JWT)
02-manager              /manager/*
03-agents                /agents/*
04-rules                 /rules/*
05-security-events       /security/* , alerts/events
06-syscheck               /syscheck/* (FIM)
```

Files:
- `Wazuh-SOC-Lab.postman_collection.json` — the collection itself, exported from Postman.
- `environment.example.json` — template environment variables (`base_url`, `username`, `password`, `token`). Copy to `environment.json` (gitignored) and fill in real values locally.
- This README documents how to import both and run the auth request first to populate `{{token}}` for the rest of the collection.

This collection is built endpoint-by-endpoint, not imported wholesale from a third party — every request here should have a corresponding entry in `docs/api/wazuh-api-notes.md`.
