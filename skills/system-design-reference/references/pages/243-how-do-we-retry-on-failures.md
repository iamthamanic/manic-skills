---
page: 243
title: How do we retry on failures?
title_de: How do we retry on failures?
tags: [data, messaging, reliability]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 2.1: The data is loaded from disk to OS cache 2.2 The data is copied from OS cache to Kafka application 2.3 Kafka application copies the data into the socket buffer 2.4 The data is copied from socket ...

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 243. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 243 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, reliability).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 243 |
