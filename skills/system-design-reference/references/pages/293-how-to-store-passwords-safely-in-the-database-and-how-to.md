---
page: 293
title: How to store passwords safely in the database and how to
title_de: How to store passwords safely in the database and how to
tags: [data, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 𝐓𝐡𝐢𝐧𝐠𝐬 𝐍𝐎𝐓 𝐭𝐨 𝐝𝐨 🔹 Storing passwords in plain text is not a good idea because anyone with internal access can see
- 🔹 Storing password hashes directly is not sufficient because it is pruned to precomputation attacks,
- 🔹 To mitigate precomputation attacks, we salt the passwords. 𝐖𝐡𝐚𝐭 𝐢𝐬 𝐬𝐚𝐥𝐭 ? According to OWASP guidelines, “a salt is a unique, randomly generated string that is added to each
- 𝐇𝐨𝐰 𝐭𝐨 𝐬𝐭𝐨𝐫𝐞 𝐚 𝐩𝐚𝐬𝐬𝐰𝐨𝐫𝐝 𝐚𝐧𝐝 𝐬𝐚𝐥𝐭 ?
- 2 ⃣ The password can be stored in the database using the following format: 𝘩𝘢𝘴𝘩 ( 𝘱𝘢𝘴𝘴𝘸𝘰𝘳𝘥 + 𝘴𝘢𝘭𝘵 ). 𝐇𝐨𝐰 𝐭𝐨 𝐯𝐚𝐥𝐢𝐝𝐚𝐭𝐞 𝐚 𝐩𝐚𝐬𝐬𝐰𝐨𝐫𝐝 ?

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 293. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 293 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 293 |
