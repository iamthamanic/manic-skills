---
page: 155
title: Cloud Cost Reduction Techniques
title_de: Cloud Cost Reduction Techniques
tags: [data, architecture, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- However, Redis stores data in memory. When we restart Redis, we will lose all the data and the
- 🔹 2013 - Persistence When Redis 2.8 was released in 2013, it addressed the previous restrictions. Redis introduced RDB
- 🔹 2013 - Replication Redis 2.8 also added replication to increase availability. The primary instance handles real-time read
- 🔹 2013 - Sentinel Redis 2.8 introduced Sentinel to monitor the Redis instances in real time. is a system designed to
- 🔹 2015 - Cluster In 2015, Redis 3.0 was released. It added Redis clusters. A Redis cluster is a distributed database solution that manages data through sharding. The data is
- 🔹 Looking Ahead Redis is popular because of its high performance and rich data structures that dramatically reduce
- In 2017, Redis 5.0 was released, adding the stream data type. In 2020, Redis 6.0 was released, introducing the multi-threaded I/O in the network module. Redis

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 155. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 155 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, architecture, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 155 |
