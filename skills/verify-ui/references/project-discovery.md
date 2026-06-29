# Project Discovery

Determine where the frontend lives before any Playwright or browser work.

## 1. Workspace root

Start from the user's workspace / git root. Look for:

- `.git/`
- Root `package.json`
- `AGENTS.md`

## 2. App root detection (first match wins)

| Signal | App root |
|--------|----------|
| `.qa/project.yaml` with `appRoot` | That path (relative to workspace root) |
| `package.json` with `"dev"` or `"start"` + `react`/`vue`/`svelte`/`next` | Current directory |
| `vite.config.ts` + `src/main.tsx` or `index.html` | Directory containing vite config |
| `next.config.*` | Same directory |
| Root `package.json` with `"dev": "npm run dev --prefix X"` | Subfolder `X` |
| Multiple candidates | Prefer folder named in README/AGENTS; else folder with `src/App.tsx` or `src/app/` |

**Working directory for Playwright:** always **app root**, not monorepo root (unless config lives at root).

## 3. Stack detection

Inspect app root `package.json` dependencies:

| Dependency | Stack | Default port |
|------------|-------|--------------|
| `vite` | Vite | 5173 (override in vite.config / env) |
| `next` | Next.js | 3000 |
| `react-scripts` | CRA | 3000 |
| `@remix-run/*` | Remix | 3000 |
| None of above + only `express`/`fastify` | API-only | — |

## 4. Dev URL resolution

Priority:

1. `.qa/project.yaml` → `devUrl`
2. `vite.config.*` → `server.port` or env like `VITE_DEV_PORT`
3. `next.config.*` / README
4. Stack default

Build full URL: `http://localhost:<port>`

## 5. Checks command

Priority:

1. `.qa/project.yaml` → `checksCommand`
2. Root or app `package.json` → `"checks"`
3. `AGENTS.md` validation section
4. Fallback: `npm run build && npm test`

Run from the directory where the script is defined (workspace root if it uses `--prefix`).

## 6. No frontend

If no HTML entry, no `react-dom`, no `dev` script:

- Report: API/library project
- Skip Playwright bootstrap
- Suggest unit/integration tests only
