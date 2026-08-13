# Knowledge sources — prior art search

Run **at least two** sources before `confidence: high` on root cause.

## 1. Repo grep (always)

```bash
rg -n "<error substring>" --glob '!node_modules' --glob '!dist'
rg -n "<ComponentName>" src/
```

Search: error message, route path, hook name, API adapter.

## 2. Project docs

| Path | Content |
|------|---------|
| `.qa/edge-cases.md` | Known edge cases |
| `.qa/debug-log.md` | Project debug history (optional) |
| `tickets/` | Past bugfix tickets |
| `AGENTS.md` | Constraints that cause class of bugs |
| `docs/DESKTOP_FIRST_DEV.md` | Tauri/local runtime gotchas |

## 3. GitHub (when `gh` authenticated)

```bash
gh issue list --search "error words" --limit 10
gh pr list --search "component" --limit 5
```

## 4. LightRAG (optional)

If LightRAG server running (see project `@rag-index` / `scripts/rag-start.sh`):

- `mcp__lightrag__query` with mode `hybrid`
- Question: "Where is X handled?" or "Known issues with Y?"

If offline: note in report, continue with grep only.

## 5. Global debug ledger

`~/.claude/skills/debug/ledger/*.md` — personal cross-project patterns.

Format when appending (user consent, no secrets):

```markdown
## YYYY-MM-DD | <project-slug> | <short title>
- **Symptom:** …
- **Cause:** …
- **Fix:** …
- **Tags:** tauri, react-query, …
```

## 6. Git history (narrow)

```bash
git log -n 5 --oneline -- <suspect-file>
git blame -L <line>,<line> <file>
```

Only when stack points to specific lines.

## Correlation rule

| Evidence | Required for high confidence |
|----------|------------------------------|
| Console/stack | Yes |
| Code location | Yes |
| Prior art OR second repro path | At least one |

If only one source matches, set `confidence: medium` or `low`.
