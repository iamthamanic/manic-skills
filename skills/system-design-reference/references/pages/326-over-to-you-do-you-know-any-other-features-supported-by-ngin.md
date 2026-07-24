---
page: 326
title: Over to you: Do you know any other features supported by Nginx?
title_de: Over to you: Do you know any other features supported by Nginx?
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- In 2017, Discord had 12 Cassandra nodes and stored billions of messages. At the beginning of 2022, it had 177 nodes with trillions of messages. At this point, latency was
- There are several reasons for the issue: - Cassandra uses the LSM tree for the internal data structure. The reads are more expensive than
- - Maintaining clusters, such as compacting SSTables, impacts performance.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 326. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 326 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 326 |
