---
page: 100
title: How are notifications pushed to our phones or PCs? A messaging solution (Firebase) can be used to support the notific...
title_de: How are notifications pushed to our phones or PCs? A messaging solution (Firebase) can be used to support the notific...
tags: [api, data, messaging, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- How are notifications pushed to our phones or PCs? A messaging solution (Firebase) can be used to support the notification push. The diagram below shows how Firebase Cloud Messaging (FCM) works.
- FCM is a cross-platform messaging solution that can compose, send, queue, and route notifications
- Steps 1 - 2: When the client app starts for the first time, the client app sends credentials to FCM,
- Step 3: The client app sends the Registration Token to the app server. The app server caches the

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 100. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 100 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, data, messaging, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 100 |
