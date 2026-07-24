---
page: 365
title: How to Design a System Like YouTube?
title_de: How to Design a System Like YouTube?
tags: [data, messaging, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Here’s a 9-step process: 1 - The user creates a video upload request and provides the video files along with the details about
- 5 - The transcoded video is uploaded to another object storage. 6 - The notification for transcoding completion is sent to a special service via a message queue.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 365. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 365 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 365 |
