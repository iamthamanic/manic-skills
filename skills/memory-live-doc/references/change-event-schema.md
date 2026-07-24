# Change event schema (v1)

File: `.project-memory/changes/<YYYY-MM-DD>-<slug>.json`

## Types

`feature` | `bugfix` | `security` | `data-model` | `breaking-change` | `architecture` | `dependency` | `decision` | `bootstrap`

## Required fields

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | Same as filename stem or UUID-stable slug |
| `date` | string | ISO date `YYYY-MM-DD` |
| `type` | string | One of Types above |
| `status` | string | e.g. `recorded` \| `draft` |
| `title` | `{ de, en }` | Bilingual |
| `summary` | `{ de, en }` | Bilingual |
| `user_impact` | `{ de: string[], en: string[] }` | |
| `developer_impact` | `{ de: string[], en: string[] }` | |
| `operational_impact` | `{ de: string[], en: string[] }` | |
| `git.base` | string | SHA |
| `git.head` | string | SHA |
| `git.branch` | string | |
| `git.pull_request` | string \| null | URL when known |
| `packages` | string[] | Monorepo package names; `[]` if none |
| `affected_features` | string[] | Feature ids |
| `affected_components` | string[] | Paths or component names |
| `breaking_changes` | string[] | Empty if none |
| `migration_required` | boolean | |
| `security_relevant` | boolean | |
| `evidence` | Evidence[] | At least one entry |
| `screenshots` | Screenshot[] | May be empty; placeholders allowed |
| `confidence` | number | 0–1 |
| `review_status` | string | `needs-review` \| `accepted` \| `rejected` |

## Optional

| Field | Type |
|-------|------|
| `locked` | boolean |
| `comments` | string[] |
| `plain_language` | `{ de, en }` — what happened, in everyday language |
| `why_it_matters` | `{ de, en }` — why non-technical readers should care |

## `review_status` (documentation trust, not app runtime)

| Value | Meaning |
|-------|---------|
| `needs-review` | Agent/AI drafted this from git/code. A human should verify before treating it as product truth. |
| `accepted` | Reviewed and approved. |
| `rejected` | Wrong or obsolete; keep for audit, do not present as current. |

Pipeline apply always sets new/updated events to `needs-review` unless a field is `locked`.

## Evidence item

```json
{
  "kind": "file" | "test" | "migration" | "pr" | "blob" | "commit" | "compare",
  "path": "packages/foo/src/bar.ts",
  "sha": "optional-for-commit",
  "url": "https://github.com/org/repo/blob/<sha>/packages/foo/src/bar.ts"
}
```

At least one of `path` or `url` required. **Always prefer both** when a GitHub remote exists:

| kind | `url` shape |
|------|-------------|
| `file` / `blob` | `…/blob/<sha>/<path>` or `…/tree/<sha>/<dir>` |
| `commit` | `…/commit/<sha>` |
| `compare` | `…/compare/<base>...<head>` |
| `pr` | full PR URL |

The viewer also builds links from `project.repository.url` + `git.head` + `affected_components[]` when `url` is missing — but apply/export should still write `url` so Pages snapshots are self-contained.

## Screenshot item

```json
{
  "id": "shot-1",
  "path": "docs/memory-live-doc/assets/<change-id>/ui.png",
  "status": "present" | "missing" | "requested",
  "caption": { "de": "…", "en": "…" }
}
```

## Append-only

Never delete change event files. Correct mistakes via new events or `comments` / `review_status` updates when not `locked`.
