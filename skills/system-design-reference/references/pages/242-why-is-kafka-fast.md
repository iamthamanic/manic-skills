---
page: 242
title: Why is Kafka fast?
title_de: Why is Kafka fast?
tags: [messaging]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- There are many design decisions that contributed to Kafka’s performance. In this post, we’ll focus on
- The diagram below illustrates how the data is transmitted between producer and consumer, and
- 🔹 Step 1.1 - 1.3: Producer writes data to the disk 🔹 Step 2: Consumer reads data without zero-copy

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 242. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 242 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: messaging).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 242 |
