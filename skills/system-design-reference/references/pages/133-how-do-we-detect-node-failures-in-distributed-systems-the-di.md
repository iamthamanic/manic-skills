---
page: 133
title: How do we detect node failures in distributed systems? The diagram below shows top 6 Heartbeat Detection Mechanisms.
title_de: How do we detect node failures in distributed systems? The diagram below shows top 6 Heartbeat Detection Mechanisms.
tags: [principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Heartbeat mechanisms are crucial in distributed systems for monitoring the health and status of
- 🔹 Push-Based Heartbeat The most basic form of heartbeat involves a periodic signal sent from one node to another or to a
- 🔹 Pull-Based Heartbeat Instead of nodes sending heartbeats actively, a central monitor might periodically "pull" status

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 133. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 133 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 133 |
