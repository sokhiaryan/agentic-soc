# Agentic SOC

An open-source security operations lab: Wazuh detection, endpoint telemetry, and n8n-driven automation, built and documented as an engineering project rather than a wired-together demo.

The project explores a simple question: **can a small, personally-run SOC stack detect, enrich, and eventually help investigate real security telemetry — end to end, with a human in control of anything that acts?**

                         SECURITY LAB

                              |

                              v

                    Ubuntu Endpoint

                    Wazuh Agent \+ auditd

                              |

                              v

                     \+-----------------+

                     |  Wazuh Manager  |

                     |  Rules          |

                     |  Decoders       |

                     |  Correlation    |

                     \+--------+--------+

                              |

                              v

                     \+-----------------+

                     |    Wazuh API    |

                     \+--------+--------+

                              |

                              v

                     \+-----------------+

                     |       n8n       |

                     |   SOAR Layer    |

                     \+-----------------+

## Status

**Day 1 — Foundation \+ Wazuh \+ n8n: complete.** Docker Engine deployed and verified, the official Wazuh 4.14.7 single-node stack (Manager, Indexer, Dashboard) is up and reachable, a local Ubuntu agent is enrolled and Active, `auditd` is enabled with a Wazuh-specific audit rule, and n8n is running locally with an owner account created. Full evidence and timeline: [`docs/lab-notes/day-01-wazuh-n8n-deployment.md`](http://docs/lab-notes/day-01-wazuh-n8n-deployment.md).

See [`docs/ROADMAP.md`](http://docs/ROADMAP.md) for the full staged plan.

## Capabilities

- [x] Docker foundation (Engine \+ Compose)  
- [x] SIEM deployment (Wazuh Manager / Indexer / Dashboard, single-node)  
- [x] Endpoint telemetry (local Wazuh agent, enrolled and Active)  
- [x] Host auditing (`auditd`, Wazuh-specific execve rule)  
- [x] SOAR platform deployed (n8n, local-only)  
- [ ] Custom detection rules \+ MITRE ATT\&CK mapping  
- [ ] Wazuh REST API notebook \+ Postman collection  
- [ ] n8n workflow against the Wazuh API  
- [ ] Threat intelligence enrichment  
- [ ] Attack simulation (Atomic Red Team, guarded/reviewed)  
- [ ] Human-in-the-loop response workflow  
- [ ] Incident report generation

## Repository layout

agentic-soc/

├── docs/

│   ├── ROADMAP.md         staged build plan

│   ├── lab-notes/         dated deployment/experiment records with evidence

│   ├── wazuh/              Wazuh internals notes

│   └── api/                 Wazuh REST API notes

├── screenshots/            evidence images referenced from lab notes

├── scripts/                 bootstrap and readiness scripts (Docker, host checks, n8n, auditd, Atomic Red Team)

├── infrastructure/

│   ├── wazuh/                the official wazuh-docker single-node deployment

│   └── n8n/                   n8n compose config \+ private .env key (gitignored)

├── detections/               custom Wazuh rules and decoders, as they're written

├── postman/                  Wazuh API Postman collection, as it's built

├── tests/                    attack simulation scenarios, as they're added

├── .gitignore

└── LICENSE

Only what's actually built lives here. Directories that held nothing but a placeholder README have been removed rather than left as unfilled scaffolding — they come back once there's real content for them.

## Getting it running

./scripts/install-docker-ubuntu.sh

newgrp docker

./scripts/check-lab-host.sh

cd infrastructure/wazuh/wazuh-docker/single-node

docker compose up \-d

./scripts/bootstrap-n8n.sh

Wazuh dashboard: `https://localhost` · n8n: `http://127.0.0.1:5678` (loopback only — not exposed directly).

## Documentation philosophy

Every deployment or experiment gets a dated write-up in `docs/lab-notes/`: what was attempted, what the evidence actually shows, what broke, and what's next. Failures are documented, not deleted — a debugging note is worth more here than a changelog that pretends everything worked the first time.

## Security notes

- n8n and the Wazuh dashboard/API are bound to localhost only.  
- The `docker` group grants root-equivalent host access — accepted as reasonable for a single-user lab VM.  
- Secrets (n8n's `.env` encryption key, Wazuh certs/credentials) are gitignored and never committed.  
- Any offensive testing (Atomic Red Team) is guarded: prepared and previewed, then run only after explicit review.

## License

MIT — see `LICENSE`.  
