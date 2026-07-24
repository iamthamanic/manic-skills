---
page: 116
title: How will you design the Stack Overflow website?
title_de: How will you design the Stack Overflow website?
tags: [data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- - Hot-hot: two instances receive the same input and send the output to the
- - Hot-warm: two instances receive the same input and only the hot side sends the
- - Single-leader cluster: one leader instance receives data from the upstream system
- - Leaderless cluster: there is no leader in this type of cluster. Any write will get
- computation-intensive

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 116. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 116 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 116 |
