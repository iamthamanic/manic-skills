---
page: 276
title: 4 Ways Netflix Uses Caching to Hold User Attention
title_de: 4 Ways Netflix Uses Caching to Hold User Attention
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- The goal of Netflix is to keep you streaming for as long as possible. But a user’s typical attention
- They use EVCache (a distributed key-value store) to reduce latency so that the users don’t lose
- However, EVCache has multiple use cases at Netflix. 1 - Lookaside Cache When the application needs some data, it first tries the EVCache client and if the data is not in the
- The service also keeps the cache updated for future requests. 2 - Transient Data Store Netflix uses EVCache to keep track of transient data such as playback session information.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 276. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 276 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 276 |
