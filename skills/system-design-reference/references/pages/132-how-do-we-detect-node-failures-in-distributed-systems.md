---
page: 132
title: How do we detect node failures in distributed systems?
title_de: How do we detect node failures in distributed systems?
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- similar to a spreadsheet and is straightforward to understand and implement. However, it lacks the
- 🔹 Hierarchical Model The hierarchical data model organizes data into a tree-like structure, where each record has a single
- 🔹 Relational Model Introduced by E.F. Codd in 1970, the relational model represents data in tables (relations), consisting
- 🔹 Star Schema The star schema is a specialized data model used in data warehousing for OLAP (Online Analytical
- 🔹 Snowflake Model The snowflake model is a variation of the star schema where the dimension tables are normalized
- 🔹 Network Model The network data model allows each record to have multiple parents and children, forming a graph

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 132. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 132 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 132 |
