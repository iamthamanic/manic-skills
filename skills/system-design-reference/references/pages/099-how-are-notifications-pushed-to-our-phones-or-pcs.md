---
page: 99
title: How are notifications pushed to our phones or PCs?
title_de: How are notifications pushed to our phones or PCs?
tags: [api, messaging, networking, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Every time something interesting happens, the external service calls the endpoint and provides the
- This makes webhooks ideal for dealing with real-time updates because data is pushed to your
- So, when to use Polling or Webhook? Polling is a solid option when there is some infrastructural limitation that prevents the use of
- Webhooks are recommended for applications that need instant data delivery. Also, webhooks are

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 99. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 99 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, messaging, networking, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 99 |
