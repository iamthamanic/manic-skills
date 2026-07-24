---
page: 22
title: REST API Cheatsheet
title_de: REST API Cheatsheet
tags: [api, data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 2. Cache penetration This happens when the key doesn’t exist in the cache or the database. The application cannot
- To solve this, there are two suggestions. One is to cache a null value for non-existent keys, avoiding
- 3. Cache breakdown This is similar to the thunder herd problem. It happens when a hot key expires. A large number of
- Over to you: Have you met any of these issues in production?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 22. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 22 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 22 |
