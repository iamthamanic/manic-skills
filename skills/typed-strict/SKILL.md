---
name: typed-strict
description: >-
  Language-agnostic ban on type-system escape hatches (TypeScript any, Python Any,
  type: ignore, @ts-nocheck, etc.) plus Boy Scout: strip loose typing from every
  touched file. Use from implement, verify-ticket, review-ticket, audit-changes,
  feature-intake, ecc-runner-loop, or when AGENTS.md forbids any/loose types.
---

# Typed Strict (no loose typing)

**One shared rule for all ECC skills.** Do not copy language-specific `any` bans into each skill — apply this helper instead.

## Principle (language-agnostic)

1. **Never disable or bypass the type system** to ship code (escape hatches).
2. **Boy Scout:** every file you edit in a PR must leave with **zero** loose-typing markers for that language — fix pre-existing debt in that file, not only avoid new ones.
3. Prefer real types, schemas (Zod/Pydantic), generics, and `unknown`/`object` + immediate narrowing over casts and suppressions.
4. **Never** add linter/typechecker suppressions for this rule (`eslint-disable`, `# type: ignore`, `@ts-nocheck`, `nolint`, etc.) unless `AGENTS.md` documents a named exception.

## Resolve language for this repo

Priority:

1. `.qa/project.yaml` → `typedStrict.languages` (never use UI `language: de` / `locale` here)
2. If missing or incomplete → **auto-detect** and persist (see below)
3. `AGENTS.md` Non-Negotiables (project-specific wording can tighten severity)
4. File extensions in the **changed** path set (union with configured languages)
5. Fallback: run all matrix rows that match extensions present in the diff

### Auto-detect + persist

```bash
bash "$HOME/.cursor/skills/typed-strict/scripts/detect-languages.sh" <repo-root>
```

Algorithm: [references/stack-detect.md](references/stack-detect.md).

- **`@project-setup` init/audit:** write/append `typedStrict.languages` in `.qa/project.yaml`
- **`@ecc-check` / `@test-gate`:** if `typedStrict` missing → run detect, append to `project.yaml`, then gate on that set; if present → use as-is (append newly detected langs only when clearly missing from yaml)
- Never shrink the list without user OK

Full pattern matrix: [references/language-matrix.md](references/language-matrix.md).

Optional project override in `.qa/project.yaml`:

```yaml
typedStrict:
  languages: [typescript, python]   # subset of matrix keys
  extraPatterns:                    # optional rg patterns, changed paths only
    - 'pattern'
  allowlistPaths: []                # rare; prefer fixing over allowlisting
```

## Gate (always on changed paths)

```bash
# Pseudocode — pick patterns from language-matrix for detected languages
rg '<loose-type-pattern>' <CHANGED_PATHS>
```

| Result | Severity |
|--------|----------|
| 0 matches on touched paths | PASS |
| >0 matches on touched paths | **FAIL / BLOCK** (Boy Scout incomplete) |
| Matches only outside touched files | Ignore for this ticket (legacy debt) |

## When each caller applies this

| Caller | When |
|--------|------|
| `@implement` | While coding + before claiming done — strip loose types in every edited file |
| `@verify-ticket` | Diff gate: FAIL if touched paths still match matrix |
| `@review-ticket` | Important finding if escape hatches remain; blocks ACCEPT |
| `@audit-changes` | Phase A/B RG gate on scoped paths → BLOCK if matches |
| `@feature-intake` | Slice acceptance must require typed-strict / Boy Scout; no tickets that introduce loose typing |
| `@ecc-runner-loop` | Inherited via implement → verify → review; do not skip |
| `@project-setup` | init/audit — auto-detect + write `typedStrict.languages` |
| `@ecc-check` | Phase A = `@test-gate` (includes typed-strict Boy Scout) |
| `@test-gate` | Always runs `@typed-strict` as part of the matrix |

## Out of scope

- Do **not** rewrite the whole repo in an unrelated feature ticket.
- Dynamic languages without a typechecker still forbid **explicit** opt-outs and `Any`-style annotations when a checker (mypy/pyright/tsc) is in use.
- Generated code / vendor: skip if `AGENTS.md` or `allowlistPaths` says so.

## Report snippet (for verify / audit / review)

```markdown
### Typed-strict
- Languages: …
- Touched-path matches: 0 | N (list file:line)
- Verdict: PASS | FAIL
```
