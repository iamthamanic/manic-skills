---
page: 225
title: Top 5 common ways to improve API performance.
title_de: Top 5 common ways to improve API performance.
tags: [api, data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Result Pagination: This method is used to optimize large result sets by streaming them back to the client, enhancing
- Asynchronous Logging: This approach involves sending logs to a lock-free buffer and returning immediately, rather than
- Data Caching: Frequently accessed data can be stored in a cache to speed up retrieval. Clients check the cache
- Payload Compression: To reduce data transmission time, requests and responses can be compressed (e.g., using gzip),

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 225. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 225 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 225 |
