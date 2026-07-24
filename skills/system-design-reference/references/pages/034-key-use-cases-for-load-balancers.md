---
page: 34
title: Key Use Cases for Load Balancers
title_de: Key Use Cases for Load Balancers
tags: [api, networking]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- - Provides a single endpoint for clients to query for precisely the data they need. - Clients specify the exact fields required in nested queries, and the server returns optimized
- - Supports Mutations for modifying data and Subscriptions for real-time notifications. - Great for aggregating data from multiple sources and works well with rapidly evolving
- - However, it shifts complexity to the client side and can allow abusive queries if not properly
- - Caching strategies can be more complicated than REST.
- The best choice between REST and GraphQL depends on the specific requirements of the

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 34. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 34 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, networking).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 34 |
