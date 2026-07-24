---
page: 106
title: How do we manage sensitive data in a system?
title_de: How do we manage sensitive data in a system?
tags: [devops]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Step 4: A build is triggered in Jenkins. The source code must pass unit tests, code coverage
- Step 5: Once the build is successful, the build is stored in artifactory. Then the build is deployed into
- Step 6: There might be multiple dev teams working on different features. The features need to be
- Step 7: The QA team picks up the new QA environments and performs QA testing, regression
- Steps 8: Once the QA builds pass the QA team’s verification, they are deployed to the UAT
- Step 9: If the UAT testing is successful, the builds become release candidates and will be deployed
- Step 10: SRE (Site Reliability Engineering) team is responsible for prod monitoring. Over to you: what's your company's release process look like?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 106. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 106 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: devops).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 106 |
