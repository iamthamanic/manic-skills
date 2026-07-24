---
page: 101
title: 9 best practices for developing microservices
title_de: 9 best practices for developing microservices
tags: [api, messaging, architecture, networking, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Step 4: There are two ways to send messages. One is to compose messages directly in the console
- Step 5: FCM receives the messages, and queues the messages in the storage if the devices are not
- Step 6: FCM forwards the messages to platform-level transport. This transport layer handles
- Step 7: The messages are routed to the targeted devices. The notifications can be displayed
- Over to you: We can also send messages to a “topic” (just like Kafka) in Step 4. When should the
- Reference Material: Google firebase documentation

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 101. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 101 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, messaging, architecture, networking, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 101 |
