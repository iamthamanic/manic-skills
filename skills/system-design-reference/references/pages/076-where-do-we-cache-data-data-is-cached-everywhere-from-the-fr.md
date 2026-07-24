---
page: 76
title: Where do we cache data? Data is cached everywhere, from the front end to the back end!
title_de: Where do we cache data? Data is cached everywhere, from the front end to the back end!
tags: [api, data, networking]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- There are 𝐦𝐮𝐥𝐭𝐢𝐩𝐥𝐞 𝐥𝐚𝐲𝐞𝐫𝐬 along the flow. 1. Client apps: HTTP responses can be cached by the browser. We request data over HTTP for
- 2. CDN: CDN caches static web resources. The clients can retrieve data from a CDN node
- 3. Load Balancer: The load Balancer can cache resources as well.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 76. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 76 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, networking).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 76 |
