---
page: 167
title: You're Decent at Linux if You Know What Those Directories Mean :)
title_de: You're Decent at Linux if You Know What Those Directories Mean :)
tags: [messaging, devops]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- The diagram below shows how a message can be lost during its lifecycle in Kafka. 🔹 Producer When we call producer.send() to send a message, it doesn't get sent to the broker directly. There are
- 1. Application thread 2. Record accumulator 3. Sender thread (I/O thread) We need to configure proper ‘acks’ and ‘retries’ for the producer to make sure messages are sent to
- 🔹 Broker A broker cluster should not lose messages when it is functioning normally. However, we need to
- 1. The messages are usually flushed to the disk asynchronously for higher I/O throughput, so if the
- 2. The replicas in the Kafka cluster need to be properly configured to hold a valid copy of the data.
- 🔹 Consumer Kafka offers different ways to commit messages. Auto-committing might acknowledge the
- A good practice is to combine both synchronous and asynchronous commits, where we use

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 167. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 167 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: messaging, devops).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 167 |
