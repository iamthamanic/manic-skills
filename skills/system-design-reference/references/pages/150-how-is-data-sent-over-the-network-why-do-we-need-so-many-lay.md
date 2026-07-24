---
page: 150
title: How is data sent over the network? Why do we need so many layers in the OSI model? The diagram below shows how data i...
title_de: How is data sent over the network? Why do we need so many layers in the OSI model? The diagram below shows how data i...
tags: [api, networking, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- How is data sent over the network? Why do we need so many layers in the OSI model? The diagram below shows how data is encapsulated and de-encapsulated when transmitting over
- Step 1: When Device A sends data to Device B over the network via the HTTP protocol, it is first
- Step 2: Then a TCP or a UDP header is added to the data. It is encapsulated into TCP segments at
- Step 3: The segments are then encapsulated with an IP header at the network layer. The IP header
- Step 4: The IP datagram is added a MAC header at the data link layer, with source/destination MAC

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 150. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 150 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, networking, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 150 |
