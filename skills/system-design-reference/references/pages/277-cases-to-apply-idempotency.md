---
page: 277
title: Cases to Apply Idempotency
title_de: Cases to Apply Idempotency
tags: [data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- One application service might start the session while the other may update the session followed by a
- 3 - Primary Store Netflix runs large-scale pre-compute systems every night to compute a brand-new home page for
- All of that data is written into the EVCache cluster from where the online services read the data and
- 4 - High Volume Data Netflix has data that has a high volume of access and also needs to be highly available. For
- A separate process asynchronously computes and publishes the UI string to EVCache from where

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 277. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 277 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 277 |
