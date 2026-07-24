---
page: 205
title: GET, POST, PUT... Common HTTP “verbs” in one figure
title_de: GET, POST, PUT... Common HTTP “verbs” in one figure
tags: [api, networking]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 1. HTTP GET This retrieves a resource from the server. It is idempotent. Multiple identical requests return the
- 2. HTTP PUT This updates or Creates a resource. It is idempotent. Multiple identical requests will update the same
- 3. HTTP POST This is used to create new resources. It is not idempotent, making two identical POST will duplicate

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 205. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 205 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, networking).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 205 |
