# Project RG Gates (diff-scoped)

Run these **only on changed paths** when `AGENTS.md` or project rules define them. Discover patterns from the repo; do not hardcode product names.

## Discovery

1. Read `AGENTS.md` § Pre-Commit / Non-Negotiables
2. Read `.cursor/rules/*.mdc` if present
3. Apply **`@typed-strict`** language matrix for extensions in the diff (`~/.cursor/skills/typed-strict/references/language-matrix.md`)
4. If nothing found, skip section and note in report

## Common gates (examples)

Adjust paths to `CHANGED_PATHS` or diff file list.

```bash
# Tailwind arbitrary values (frontend)
rg '\bclass[Nn]ame=.*\b[a-z-]+-\[[^\]]+\]' frontend/src --glob '<changed-files>'

# Cross-module imports (backend modules)
rg "from '\.\./\.\./" backend/app/modules --glob '<changed-files>'
rg "from '.*common.*'" backend/app/modules --glob '<changed-files>'

# Loose typing — prefer @typed-strict matrix (not TS-only). Examples:
rg ': any\b|as any\b' --glob '<changed-ts-files>'
rg '\bAny\b|type:\s*ignore' --glob '<changed-py-files>'
rg '@ts-ignore|@ts-nocheck|eslint-disable.*no-explicit-any' --glob '<changed-files>'

# console.log in services
rg 'console\.(log|error|warn)' --glob '<changed-files>' --type ts

# Secrets in diff (never log full matches)
git diff | rg -i 'sk-|api[_-]?key|password\s*=\s*["\x27]|Bearer [A-Za-z0-9._-]{20,}'
```

## Project-specific security (multi-tenant example)

If AGENTS.md mentions `organizationId`:

```bash
rg 'findUnique\(\s*\{\s*where:\s*\{\s*id' --glob '<changed-service-files>'
# Flag: prefer findFirst with organizationId
```

## Result

| Gate | Match count | Severity |
|------|-------------|----------|
| 0 | PASS | — |
| >0 in diff | FAIL | BLOCK unless documented exception |

List exact file:line in report findings table.

**Typed-strict:** any match of the language-matrix escape hatches on touched paths is **BLOCK** (Boy Scout). Legacy debt outside the scoped paths is ignored for this audit.
