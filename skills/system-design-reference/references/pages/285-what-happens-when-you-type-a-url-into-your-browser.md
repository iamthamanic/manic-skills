---
page: 285
title: What happens when you type a URL into your browser?
title_de: What happens when you type a URL into your browser?
tags: [api, data, networking]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- The diagram below illustrates the steps. 1. Bob enters a URL into the browser and hits Enter. In this example, the URL is composed of 4
- 2.1 If the IP address cannot be found at any of the caches, the browser goes to DNS servers to do a
- 3. Now that we have the IP address of the server, the browser establishes a TCP connection with
- 4. The browser sends an HTTP request to the server. The request looks like this: 𝘎𝘌𝘛 / 𝘱𝘩𝘰𝘯𝘦 𝘏𝘛𝘛𝘗 /1.1

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 285. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 285 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, networking).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 285 |
