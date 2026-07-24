---
page: 270
title: What is SSO (Single Sign-On)?
title_de: What is SSO (Single Sign-On)?
tags: [security]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Basically, Single Sign-On (SSO) is an authentication scheme. It allows a user to log in to different
- The diagram below illustrates how SSO works. Step 1: A user visits Gmail, or any email service. Gmail finds the user is not logged in and so
- Steps 2-3: The SSO authentication server validates the credentials, creates the global session for
- Steps 4-7: Gmail validates the token in the SSO authentication server. The authentication server
- Step 8: From Gmail, the user navigates to another Google-owned website, for example, YouTube. Steps 9-10: YouTube finds the user is not logged in, and then requests authentication. The SSO

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 270. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 270 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: security).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 270 |
