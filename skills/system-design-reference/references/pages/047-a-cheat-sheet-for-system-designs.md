---
page: 47
title: A cheat sheet for system designs
title_de: A cheat sheet for system designs
tags: [architecture, principles]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- We attempted to explain how it works in the diagram below. The process can be broken down into
- 1. Training. To train a ChatGPT model, there are two stages: ● Pre-training: In this stage, we train a GPT model (decoder-only transformer) on a
- ● Fine-tuning: This stage is a 3-step process that turns the pre-trained model into a
- 1. Collect training data (questions and answers), and fine-tune the pre-trained
- 2. Collect more data (question, several answers) and train a reward model to
- 3. Use reinforcement learning (PPO optimization) to fine-tune the model so the
- 2. Answer a prompt ● Step 1: The user enters the full question, “Explain how a classification algorithm

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 47. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 47 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: architecture, principles).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 47 |
