# Feature schema (v1)

File: `.project-memory/features/<feature-id>.json`

## Required

| Field | Type |
|-------|------|
| `id` | string (kebab-case) |
| `title` | `{ de, en }` |
| `summary` | `{ de, en }` |
| `status` | `planned` \| `active` \| `incomplete` \| `deprecated` |
| `packages` | string[] |
| `paths` | string[] (globs or concrete paths for heuristics) |
| `review_status` | `needs-review` \| `accepted` \| `rejected` |
| `confidence` | number 0–1 |

## Optional

| Field | Type |
|-------|------|
| `locked` | boolean — if true, never overwrite locked fields; append warnings only |
| `locked_fields` | string[] — e.g. `["title", "summary"]` |
| `plain_language` | `{ de, en }` — non-technical explanation (shown first in viewer) |
| `why_it_matters` | `{ de, en }` — why this feature exists for the product/users |
| `user_impact` | `{ de: string[], en: string[] }` |
| `related_changes` | string[] (change ids) |
| `screenshots` | Screenshot[] (same shape as change events) |
| `notes` | `{ de, en }` |

**Viewer rule:** Prefer `plain_language` for the card body; put `summary` under “Technische Kurzfassung” / “Technical summary”. Keep `developer_impact`-style detail in related changes, not as the only text.

## Path heuristics

On incremental update, map changed files → features via:

1. Exact / prefix match on `paths[]`
2. Package name from path (`packages/<name>/`, `apps/<name>/`)
3. If no match: create or update a best-effort feature only when material; mark `needs-review`

## Monorepo

Always set `packages[]` when the feature lives in one or more workspace packages.
