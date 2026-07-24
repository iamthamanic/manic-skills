---
page: 229
title: What’s the difference between Session-based authentication and JWTs?
title_de: What’s the difference between Session-based authentication and JWTs?
tags: [security, data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- - Hold and Wait - No Preemption - Circular Wait 🔹 Deadlock Prevention - Resource ordering: impose a total ordering of all resource types, and require that each process
- - Timeouts: A process that holds resources for too long can be rolled back. - Banker’s Algorithm: A deadlock avoidance algorithm that simulates the allocation of resources to
- 🔹 Deadlock Recovery - Selecting a victim: Most modern Database Management Systems (DBMS) and Operating Systems
- - Rollback: The database may roll back the entire transaction or just enough of it to break the
- Over to you: have you solved any tricky deadlock issues?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 229. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 229 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: security, data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 229 |
