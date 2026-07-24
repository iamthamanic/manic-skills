---
page: 240
title: Azure Services Cheat Sheet
title_de: Azure Services Cheat Sheet
tags: [api, security, networking, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- - Hash the string: Use a cryptographic hash function, like HMAC (Hash-based Message
- 🔹 Send the requests When designing an API, deciding what should be included in HTTP request parameters is crucial.
- - Authentication Credentials - Timestamp: To prevent replay attacks. - Request-specific Data: Necessary to process the request, such as user IDs, transaction details, or
- - Nonces: Randomly generated strings included in each request to ensure that each request is
- 🔹 Security guidelines To safeguard APIs against common vulnerabilities and threats, adhere to these security guidelines.

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 240. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 240 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, security, networking, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 240 |
