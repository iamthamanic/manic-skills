---
name: system-design-reference
description: >-
  Evidence library for system design and software architecture (APIs, caching,
  messaging, databases, security, scalability, trade-offs). Sourced from
  ByteByteGo-style LinkedIn cheat sheets (2024 Blue). Use when designing systems,
  comparing architecture options, reviewing infra choices, or when @pingpong-solution,
  @feature-intake, or @review-ticket need pattern evidence. Bilingual EN/DE summaries.
disable-model-invocation: true
---

# System Design Reference

Global **architecture evidence library** — project-agnostic. Complements `@foundations` (theory), `@api-design` (REST contracts), `@security-review` (implementation security).

## Assets

| Path | Purpose |
|------|---------|
| `assets/linkedin-posts-2024-blue.pdf` | Original 368-page infographic collection |
| `references/index.md` | Full lookup table (all pages) |
| `references/pages/*.md` | One file per PDF page (EN + DE sections) |

## When to load

- Architecture or scaling decisions (sync vs async, cache, queue, DB choice)
- API style (REST vs GraphQL vs gRPC)
- Reliability (retry, fault tolerance, CAP trade-offs)
- Security patterns (OAuth, JWT, XSS) — **cite here; enforce with `@security-review`**
- `@pingpong-solution` Step 4–5 (options + cross-domain matrix)
- `@feature-intake` epic design (data flow, infra slices)
- `@review-ticket` when PR adds cache, queue, gateway, or distributed pattern

**Skip** for typo fixes, pure UI styling, single-line bugfixes.

## Lookup protocol (mandatory when attached)

1. Restate the architecture question in **one sentence**.
2. Search `references/index.md` and `references/pages/` by keywords (EN and DE).
3. Read **at most 4** matching `references/pages/*.md` files (highest tag/title overlap).
4. If text summary is thin (`ingest: text-extract-v1`), open PDF page from frontmatter `page:` field.
5. Recommend as **Option A / B** with trade-offs; **cite page numbers** from posts.
6. If posts conflict → state both; do not flatten trade-offs.
7. Delegate: module boundaries → `@foundations`; endpoint shape → `@api-design`; code security → `@security-review`; YAGNI scope → `@ponytail`.

## Language

- Project locale `de` or German ticket → prefer **Zusammenfassung (DE)**; use EN for precision/citations.
- English ticket → prefer **Summary (EN)**.
- Do not load all bilingual blocks if one language suffices.

## Ingest / enrichment

Text extract v1 is automatic. For diagram-rich pages, run:

```bash
python3 ~/.claude/skills/system-design-reference/scripts/ingest-pages.py --pages 8-20
python3 ~/.claude/skills/system-design-reference/scripts/ingest-pages.py --all
```

Vision/API enrichment fills **Diagram**, bilingual summaries, and **Trade-offs** tables.

## Output format (when advising)

```markdown
## Recommendation
<1–2 sentences>

## Evidence
- [page N] Title — key point
- [page M] Title — counterpoint / trade-off

## Trade-offs
| Choice | Pros | Cons |
|--------|------|------|

## Helpers used
@foundations / @api-design / @security-review (if any)
```

## Related skills

| Skill | Role |
|-------|------|
| `@foundations` | Module boundaries, contracts, essential vs accidental complexity |
| `@api-design` | Concrete REST endpoint design |
| `@security-review` | Security implementation gate |
| `@pingpong-solution` | Pre-implementation design artifact |
| `@ponytail` | Scope control — pattern may be overkill |
