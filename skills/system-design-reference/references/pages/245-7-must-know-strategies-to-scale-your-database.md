---
page: 245
title: 7 must-know strategies to scale your database
title_de: 7 must-know strategies to scale your database
tags: [data, reliability, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- Linear jitter backoff modifies the linear backoff strategy by introducing randomness to the retry
- Advantages: The randomness helps spread out the retry attempts over time, reducing the chance of
- Disadvantages: Although better than simple linear backoff, this strategy might still lead to potential
- 🔹 Exponential Backoff Exponential backoff involves increasing the delay between retries exponentially. The interval might
- Advantages: Significantly reduces the load on the system and the likelihood of collision or overlap in
- Disadvantages: In situations where a quick retry might resolve the issue, this approach can
- 🔹 Exponential Jitter Backoff Exponential jitter backoff combines exponential backoff with randomness. After each retry, the

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 245. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 245 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: data, reliability, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 245 |
