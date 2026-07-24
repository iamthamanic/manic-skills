---
page: 308
title: Which latency numbers you should know?
title_de: Which latency numbers you should know?
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Please note those are not precise numbers. They are based on some online benchmarks (Jeff
- 🔹 L1 and L2 caches: 1 ns, 10 ns E.g.: They are usually built onto the microprocessor chip. Unless you work with hardware directly,
- 🔹 RAM access: 100 ns E.g.: It takes around 100 ns to read data from memory. Redis is an in-memory data store, so it takes
- 🔹 Send packet CA->Netherlands->CA: 100 ms E.g.: If we have a long-distance Zoom call, the latency might be around 100 ms.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 308. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 308 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 308 |
