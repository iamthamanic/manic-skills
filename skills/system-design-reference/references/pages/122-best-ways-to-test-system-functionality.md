---
page: 122
title: Best ways to test system functionality
title_de: Best ways to test system functionality
tags: [general]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- And it brought down clone times from 40 minutes to a staggering 30 seconds.
- For reference, Pinboard is the oldest and largest monorepo at Pinterest. Some facts about it:
- - 350K commits - 20 GB in size when cloned fully - 60K git pulls on every business day
- Cloning monorepos having a lot of code and history is time consuming. This was exactly what was
- The build pipeline (written in Groovy) started with a “Checkout” stage where the repository was
- The clone options were set to shallow clone, no fetching of tags and only fetching the last 50
- But it missed a vital piece of optimization.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 122. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 122 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: general).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 122 |
