---
page: 222
title: Netflix's Overall Architecture
title_de: Netflix's Overall Architecture
tags: [data, messaging, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 1 - Data Modification: A change is made to the data in the source database. It could be an insert,
- 2 - Change Capture: A CDC tool monitors the database transaction logs to capture the
- 3 - Change Processing: The captured changes are processed and transformed into a format suitable
- 4 - Change Propagation: The processed changes are published to a message queue and
- 5 - Real-Time Integration: The CDC tool uses its sink connector to consume the log and update the
- Users only need to take care of step 1 while all other steps are transparent. A popular CDC solution uses Debezium with Kafka Connect to stream data changes from the source
- Over to you: have you leveraged CDC in your application before?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 222. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 222 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, messaging, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 222 |
