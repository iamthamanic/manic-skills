---
page: 231
title: Cases Behind 100% CPU Usage
title_de: Cases Behind 100% CPU Usage
tags: [security, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 3 - The JWT is passed to the client, either as a cookie or in the response body. Both approaches
- 4 - For every subsequent request, the browser sends the cookie with the JWT. 5 - The server verifies the JWT using the secret private key and extracts the user info.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 231. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 231 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: security, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 231 |
