---
page: 177
title: Architectural Patterns for Data and Communication Flow
title_de: Architectural Patterns for Data and Communication Flow
tags: [api, architecture]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 1 - API Gateway Netflix follows a microservices architecture. Every piece of functionality and data is owned by a
- This means that rendering one screen (such as the List of List of Movies or LOLOMO) involved
- Netflix initially used the API Gateway pattern using Zuul to handle the orchestration. 2 - BFFs with Groovy & RxJava Using a single gateway for multiple clients was a problem for Netflix because each client (such as
- To handle this, Netflix used the Backend-for-Frontend (BFF) pattern. Zuul was moved to the role of a
- In this pattern, every frontend or UI gets its own mini backend that performs the request fanout and
- The BFFs were built using Groovy scripts and the service fanout was done using RxJava for thread
- 3 - GraphQL Federation The Groovy and RxJava approach required more work from the UI developers in creating the

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 177. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 177 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, architecture).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 177 |
