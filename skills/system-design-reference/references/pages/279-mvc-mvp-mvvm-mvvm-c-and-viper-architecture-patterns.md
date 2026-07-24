---
page: 279
title: MVC, MVP, MVVM, MVVM-C, and VIPER architecture patterns
title_de: MVC, MVP, MVVM, MVVM-C, and VIPER architecture patterns
tags: [data, messaging, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- We need to ensure that reapplying a transaction does not change the database state beyond the
- 5. User Account Management We need to ensure that retrying a registration request does not create multiple user accounts. Also,
- 6. Distributed Systems and Messaging We need to ensure that reprocessing messages from a queue does not result in duplicate

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 279. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 279 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 279 |
