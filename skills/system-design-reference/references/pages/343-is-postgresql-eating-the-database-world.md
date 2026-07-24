---
page: 343
title: Is PostgreSQL eating the database world?
title_de: Is PostgreSQL eating the database world?
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 3 Selecting the Shard Key - Choosing an appropriate shard key is crucial for an effective sharding strategy. Designers should
- - Cardinality: Number of possible values that a shard key can have. It’s better to have a shard key
- - Frequency: Represents how often a particular shard key value appears. Higher frequency can
- - Monotonic Change: Refers to the shard key value increasing or decreasing over time. Monotonic
- 4 Request Routing - With sharding, the most critical consideration is determining which query should go to which shard.
- - Shard-aware Node: The client can contact any node and the node will serve/redirect the request to
- - Routing Tier: Client requests go to a dedicated routing tier that determines the node responsible for

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 343. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 343 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 343 |
