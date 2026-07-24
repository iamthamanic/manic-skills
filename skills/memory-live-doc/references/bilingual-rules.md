# Bilingual rules

## JSON (always)

```json
{
  "title": { "de": "…", "en": "…" },
  "summary": { "de": "…", "en": "…" },
  "user_impact": { "de": ["…"], "en": ["…"] },
  "developer_impact": { "de": ["…"], "en": ["…"] },
  "operational_impact": { "de": ["…"], "en": ["…"] }
}
```

Never leave `de` or `en` empty for required bilingual fields. If uncertain, write best-effort EN and mark `needs-review`.

## Markdown

| Locale | Paths |
|--------|-------|
| DE (primary) | `docs/PROJECT-STATUS.md`, `docs/FEATURES.md`, `docs/CHANGELOG.md`, `docs/DECISIONS.md` |
| EN | `docs/en/PROJECT-STATUS.md`, `docs/en/FEATURES.md`, `docs/en/CHANGELOG.md`, `docs/en/DECISIONS.md` |

Render from JSON; do not treat Markdown as source of truth.

## Viewer

Language toggle reads JSON snapshot under `viewer/data/`. Prefer JSON over parsing Markdown.

## Tone

- DE docs: clear project German (Du/Sie consistent with existing repo docs)
- EN docs: concise technical English
- Impacts: concrete, evidence-linked; no marketing fluff
