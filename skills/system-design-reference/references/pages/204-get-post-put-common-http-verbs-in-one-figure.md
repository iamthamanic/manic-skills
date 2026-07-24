---
page: 204
title: GET, POST, PUT... Common HTTP “verbs” in one figure
title_de: GET, POST, PUT... Common HTTP “verbs” in one figure
tags: [api, architecture, networking, devops]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- The Netflix API architecture went through 4 main stages. 𝐌𝐨𝐧𝐨𝐥𝐢𝐭𝐡 . The application is packaged and deployed as a monolith, such as a single Java WAR file,
- 𝐃𝐢𝐫𝐞𝐜𝐭 𝐚𝐜𝐜𝐞𝐬𝐬 . In this architecture, a client app can make requests directly to the microservices. With
- 𝐆𝐚𝐭𝐞𝐰𝐚𝐲 𝐚𝐠𝐠𝐫𝐞𝐠𝐚𝐭𝐢𝐨𝐧 𝐥𝐚𝐲𝐞𝐫 . Some use cases may span multiple services, we need a gateway
- 𝐅𝐞𝐝𝐞𝐫𝐚𝐭𝐞𝐝 𝐠𝐚𝐭𝐞𝐰𝐚𝐲 . As the number of developers grew and domain complexity increased, developing

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 204. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 204 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, architecture, networking, devops).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 204 |
