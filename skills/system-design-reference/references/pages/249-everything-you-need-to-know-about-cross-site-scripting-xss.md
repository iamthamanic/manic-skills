---
page: 249
title: Everything You Need to Know About Cross-Site Scripting (XSS)
title_de: Everything You Need to Know About Cross-Site Scripting (XSS)
tags: [api, security, data, messaging, architecture, networking, devops, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 2 - Reddit started using jQuery in early 2009. Later on, they started using Typescript and have now
- 3 - Within the application stack, the load balancer sits in front and routes incoming requests to the
- 4 - Reddit started as a Python-based monolithic application but has since started moving to
- 5 - Reddit heavily uses GraphQL for its API layer. In early 2021, they started moving to GraphQL
- 6 - From a data storage point of view, Reddit relies on Postgres for its core data model. To reduce
- 7 - To support data replication and maintain cache consistency, Reddit uses Debezium to run a
- 8 - Expensive operations such as a user voting or submitting a link are deferred to an async job

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 249. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 249 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, security, data, messaging, architecture, networking, devops, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 249 |
