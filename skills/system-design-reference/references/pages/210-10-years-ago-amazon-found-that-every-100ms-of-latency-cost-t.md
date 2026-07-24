---
page: 210
title: 10 years ago, Amazon found that every 100ms of latency cost them 1% in sales
title_de: 10 years ago, Amazon found that every 100ms of latency cost them 1% in sales
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 🔹 Hash-Based Sharding In this method, a hash function is applied to a shard key chosen from the data (like a customer ID or
- This tends to distribute data more evenly across shards compared to range-based sharding.
- 🔹 Consistent Hashing This is an extension of hash-based sharding that reduces the impact of adding or removing shards.
- 🔹 Virtual Bucket Sharding Data is mapped into virtual buckets, and these buckets are then mapped to physical shards. This

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 210. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 210 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 210 |
