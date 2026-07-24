---
page: 149
title: Step 5: gRPC sends the packets over the network via HTTP2. Because of binary encoding and
title_de: Step 5: gRPC sends the packets over the network via HTTP2. Because of binary encoding and
tags: [api, networking]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Steps 6 - 8: The payment service (gRPC server) receives the packets from the network, decodes
- Steps 9 - 11: The result is returned from the server application, and gets encoded and sent to the
- Steps 12 - 14: The order service receives the packets, decodes them, and sends the result to the
- Over to you: Have you used gPRC in your project? What are some of its limitations?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 149. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 149 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, networking).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 149 |
