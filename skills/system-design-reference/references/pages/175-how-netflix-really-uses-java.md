---
page: 175
title: How Netflix Really Uses Java?
title_de: How Netflix Really Uses Java?
tags: [api, data, messaging, architecture, networking, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- This pattern aims at providing determinism for long-running backend tasks. It decouples backend
- In the diagram below, the client makes a synchronous call to the API, triggering a long-running
- 🔹 Publisher-Subscriber This pattern targets decoupling senders from consumers, and avoiding blocking the sender to wait
- 🔹 Claim Check This pattern solves the transmision of large messages. It stores the whole message payload into a
- 🔹 Priority Queue This pattern prioritizes requests sent to services so that requests with a higher priority are received
- 🔹 Saga Saga is used to manage data consistency across multiple services in distributed systems, especially
- The saga pattern addresses the challenge of maintaining data consistency without relying on

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 175. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 175 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, messaging, architecture, networking, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 175 |
