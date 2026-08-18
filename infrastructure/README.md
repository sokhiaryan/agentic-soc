# infrastructure/

Docker Compose files and configuration for the two platforms this lab runs:

- `wazuh/` — the official single-node Wazuh stack (manager, indexer, dashboard), deployed from the upstream `wazuh/wazuh-docker` repo rather than a copied compose file. See `docs/lab-notes/` for the deployment lab note and `docs/architecture/` for the component breakdown.
- `n8n/` — the n8n SOAR layer compose file and any supporting config (webhook config, persistence volume).

Certificates, `.env` files, and runtime data volumes are gitignored — see the root `.gitignore`. Only configuration that should be reproducible from a clean clone belongs here.
