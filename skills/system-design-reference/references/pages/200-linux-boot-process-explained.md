---
page: 200
title: Linux Boot Process Explained
title_de: Linux Boot Process Explained
tags: [data, messaging, devops]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Contrary to LRU, the MRU algorithm removes the most recently used items first. This strategy can
- 🔹 SLRU (Segmented LRU) SLRU divides the cache into two segments: a probationary segment and a protected segment. New
- 🔹 LFU (Least Frequently Used) LFU algorithm evicts the items with the lowest access frequency. 🔹 FIFO (First In First Out) FIFO is one of the simplest caching strategies, where the cache behaves in a queue-like manner,
- 🔹 TTL (Time-to-Live) While not strictly an eviction algorithm, TTL is a strategy where each cache item is given a specific
- 🔹 Two-Tiered Caching In Two-Tiered Caching strategy, we use an in-memory cache for the first layer and a distributed
- 🔹 RR (Random Replacement) Random Replacement algorithm randomly selects a cache item and evicts it to make space for new

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 200. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 200 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, devops).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 200 |
