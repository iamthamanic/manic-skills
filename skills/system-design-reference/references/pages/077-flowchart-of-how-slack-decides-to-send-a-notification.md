---
page: 77
title: Flowchart of how slack decides to send a notification
title_de: Flowchart of how slack decides to send a notification
tags: [data, messaging, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 4. Messaging infra: Message brokers store messages on disk first, and then consumers
- 5. Services: There are multiple layers of cache in a service. If the data is not cached in the CPU
- 6. Distributed Cache: Distributed cache like Redis hold key-value pairs for multiple services in
- 7. Full-text Search: we sometimes need to use full-text searches like Elastic Search for

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 77. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 77 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 77 |
