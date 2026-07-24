# Discovery Rules

Determine project shape before creating files. Reuses logic from verify-ui project-discovery.

## 1. Workspace root

Start from user's workspace / git root. Signals:

- `.git/`
- Root `package.json`
- `AGENTS.md`

## 2. App root (first match wins)

| Signal | App root |
|--------|----------|
| `.qa/setup-profile.yaml` → `appRoot` | That path |
| `.qa/project.yaml` → `appRoot` | That path |
| `package.json` with `dev`/`start` + react/vue/svelte/next | Current directory |
| `vite.config.*` + `src/main.tsx` or `index.html` | Directory with vite config |
| `next.config.*` | Same directory |
| Root `package.json` with `"dev": "npm run dev --prefix X"` | Subfolder `X` |
| Multiple candidates | README/AGENTS mention; else folder with `src/App.tsx` or `src/app/` |

Record **app root relative to workspace root** for `.qa/project.yaml`.

## 3. Stack profile

Inspect app root `package.json` dependencies:

| Dependency | Profile | Default port |
|------------|---------|--------------|
| `vite` + `react` | `vite-react` | 5173 |
| `next` | `next` | 3000 |
| `react-scripts` | `cra` | 3000 |
| `@remix-run/*` | `next` (treat as next-like) | 3000 |
| Monorepo: workspaces + multiple apps | `monorepo` | per app |
| None of above + only express/fastify/deno | `api-only` | — |
| Unclear | `unknown` | 3000 |

## 4. Frontend detection

Has frontend when ANY:

- `react-dom` or `vue` or `svelte` in dependencies
- HTML entry (`index.html`, `src/main.tsx`, `src/app/`)
- `dev` script starts a web server

No frontend → skip styleguide, empty `navigation` in project.yaml, note API-only in report.

## 5. Dev URL

Priority:

1. `.qa/project.yaml` or setup-profile → `devUrl`
2. `vite.config.*` → `server.port`
3. `next.config.*` / README
4. Stack default

Format: `http://localhost:<port>`

## 6. Locale guess

| Signal | locale |
|--------|--------|
| User rules / chat in German | `de` |
| Existing UI strings mostly German | `de` |
| PRD/AGENTS in German | `de` |
| Otherwise | `en` |

## 7. Checks command

Priority:

1. `.qa/project.yaml` → `checksCommand` / `testGate`
2. `package.json` → `"checks"` / `"verify"`
3. `scripts/run-checks.sh` exists → `npm run checks` or `./scripts/run-checks.sh`
4. Fallback: `npm run build && npm test` (document in report)

Agents run these via **`@test-gate`** (not ad-hoc). On init, write `testGate` defaults from `~/.cursor/skills/test-gate/references/config-schema.md`. Stack profile: `bash ~/.cursor/skills/test-gate/scripts/detect-stack.sh <root>`.

## 8. PRD search paths

Glob (case-insensitive):

- `docs/PRD.md`
- `PRD.md`
- `docs/**/*prd*.md`
- `**/*-prd.md`

## 9. Styleguide search paths

- Path from setup-profile or project.yaml
- `docs/UI_STYLEGUIDE.md`
- `STYLEGUIDE.md`
- `docs/design/*.md`

## 10. Audit inventory

In audit mode, build a table:

| Artifact | Status | Action |
|----------|--------|--------|
| PRD | missing / partial / ok | … |
| AGENTS.md | … | … |
| README.md | … | … |
| .qa/project.yaml | … | … |
| `.qa/project.yaml` → `typedStrict` | missing / partial / ok | auto-detect & write (see §11) |
| .qa/edge-cases.md | … | … |
| UI styleguide | … | … |
| package checks script | … | … |

Only act on rows that need work unless user asked for full regenerate.

## 11. typedStrict languages (auto-detect)

Programming languages for `@typed-strict` — **not** UI `locale` / `language: de`.

1. Prefer existing `.qa/project.yaml` → `typedStrict.languages`
2. Else (and always on audit if missing) run:

```bash
bash "$HOME/.cursor/skills/typed-strict/scripts/detect-languages.sh" <workspace-or-repo-root>
```

3. Merge with stack profile defaults (`~/.cursor/skills/typed-strict/references/stack-detect.md`)
4. **Audit:** append newly detected languages; never remove without user OK
5. Write into `project.yaml`:

```yaml
typedStrict:
  languages:
    - typescript
    - python
```

6. Include `typedStrict languages` in Discovery Summary and setup report

| Stack hint | Default languages |
|------------|-------------------|
| `vite-react` / `next` / `cra` | `typescript` |
| `api-only` (Node/TS) | `typescript` |
| `monorepo` | union of all apps (run detect on repo root) |
| Python files / pyproject | add `python` |
| `go.mod` | add `go` |
| etc. | see detect script + language-matrix |