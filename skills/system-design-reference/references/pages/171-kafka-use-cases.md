---
page: 171
title: Kafka use cases
title_de: Kafka use cases
tags: [data, messaging, devops, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Backend services: Netflix relies on ZUUL, Eureka, the Spring Boot framework, and other
- Databases: Netflix utilizes EV cache, Cassandra, CockroachDB, and other databases. Messaging/streaming: Netflix employs Apache Kafka and Fink for messaging and streaming
- Video storage: Netflix uses S3 and Open Connect for video storage. Data processing: Netflix utilizes Flink and Spark for data processing, which is then visualized using
- CI/CD: Netflix employs various tools such as JIRA, Confluence, PagerDuty, Jenkins, Gradle, Chaos

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 171. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 171 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, devops, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 171 |
