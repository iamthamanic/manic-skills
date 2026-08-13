---
name: mobile-performance-audit
description: >-
  Audit and improve Capacitor Android + web app performance: architecture
  ownership, startup readiness, rendering, uploads/sync, observability, and CI
  performance gates. Use for mobile performance audit, app slow, startup
  optimization, Capacitor performance.
disable-model-invocation: true
---

# Mobile Performance Audit

Audit and verification workflow for mobile apps (Capacitor Android shell + web frontend).

## References (read first)

- [references/audit-checklist.md](references/audit-checklist.md) — coverage requirement; mark each item pass / partial / fail / not verifiable / n/a with evidence
- [references/implementation-map.md](references/implementation-map.md) — where each kind of work belongs (web repo vs Android project vs backend)
- [references/report-format.md](references/report-format.md) — required report structure
- [assets/mobile-performance.config.json](assets/mobile-performance.config.json) — default thresholds/config

## Rules

- Evidence over intuition: every "pass" needs file, command, trace, benchmark, or production data.
- Measure production builds, not dev mode.
- Distinguish observed defects from missing measurement capability.
- Never place privileged observability credentials or backend APM code in the mobile client.
