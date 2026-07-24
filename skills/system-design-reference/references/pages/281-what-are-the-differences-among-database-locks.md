---
page: 281
title: What are the differences among database locks?
title_de: What are the differences among database locks?
tags: [data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- In database management, locks are mechanisms that prevent concurrent access to data to ensure
- Here are the common types of locks used in databases: 1. Shared Lock (S Lock) It allows multiple transactions to read a resource simultaneously but not modify it. Other transactions
- 2. Exclusive Lock (X Lock) It allows a transaction to both read and modify a resource. No other transaction can acquire any type

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 281. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 281 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 281 |
