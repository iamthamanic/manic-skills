---
page: 283
title: How do we Perform Pagination in API Design?
title_de: How do we Perform Pagination in API Design?
tags: [api, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Pagination is crucial in API design to handle large datasets efficiently and improve performance.
- 🔹 Offset-based Pagination: This technique uses an offset and a limit parameter to define the starting point and the number of
- - Example: GET /orders?cursor=xxx - Pros: More efficient for large datasets, as it doesn't require scanning skipped records. - Cons: Slightly more complex to implement and understand.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 283. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 283 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 283 |
