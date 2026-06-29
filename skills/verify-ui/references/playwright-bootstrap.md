# Playwright Bootstrap

Install and configure Playwright **only when not already present**.

## Detection checklist

Before any install, check app root AND workspace root:

```
[ ] playwright.config.ts | .js | .mjs
[ ] package.json devDependencies["@playwright/test"]
[ ] package.json scripts["test:e2e"] | scripts["e2e"]
[ ] e2e/ or tests/e2e/ with *.spec.ts
```

**All false → bootstrap.** **Any true → use existing; do not re-init.**

## Bootstrap commands

Run in **app root**:

```bash
npm init playwright@latest -- --yes --lang=ts --install-deps
```

If npm fails (pnpm/yarn project), use the project's package manager consistently.

## Post-init configuration

### 1. playwright.config.ts

Adapt by stack. Templates in skill `templates/`:

- **Vite:** [playwright.vite.config.ts](../templates/playwright.vite.config.ts)
- **Next.js:** [playwright.next.config.ts](../templates/playwright.next.config.ts)
- **Generic:** use Vite template with manual `webServer.command`

Key settings:

```ts
testDir: './e2e',
outputDir: '.qa/test-results',
fullyParallel: true,
forbidOnly: !!process.env.CI,
retries: process.env.CI ? 2 : 0,
use: {
  baseURL: '<devUrl from discovery>',
  trace: 'on-first-retry',
  screenshot: 'only-on-failure',
},
webServer: {
  command: '<devCommand>',
  url: '<devUrl>',
  reuseExistingServer: !process.env.CI,
  timeout: 120_000,
},
```

### 2. package.json script

```json
"test:e2e": "playwright test",
"test:e2e:ui": "playwright test --ui"
```

If monorepo root orchestrates:

```json
"test:e2e": "npm run test:e2e --prefix Letzfetzprototype"
```

Add script in the package.json that owns Playwright config.

### 3. Smoke spec

Copy [smoke.app-loads.spec.ts](../templates/smoke.app-loads.spec.ts) to `e2e/smoke.app-loads.spec.ts`. Customize:

- Expected title or heading text
- Critical nav items from App

### 4. .gitignore

Add to app root `.gitignore`:

```
.qa/evidence/
.qa/test-results/
.qa/runs/
/test-results/
/playwright-report/
/blob-report/
/playwright/.cache/
```

Commit: `e2e/`, `playwright.config.ts`, script changes.  
Usually gitignore: evidence and test-results.

## Vite port detection

Read `vite.config.ts`:

- `server.port`
- `loadEnv` / `VITE_DEV_PORT`
- Default 5173

Example Letz Fetz: port **4789** via `VITE_DEV_PORT`.

## Next.js

```ts
webServer: {
  command: 'npm run dev',
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
},
```

## Preview / production build testing

For CI or pre-deploy smoke:

```ts
webServer: {
  command: 'npm run build && npm run preview',
  url: 'http://localhost:4173',
},
```

Use only when `AGENTS.md` or user requests production-mode verification.

## Running tests

```bash
# From app root
npm run test:e2e

# Single spec
npx playwright test e2e/smoke.app-loads.spec.ts

# Feature run (generated)
npx playwright test .qa/runs/2025-06-17-feature.spec.ts
```

## Updating existing Playwright

If Playwright exists but lacks smoke spec or `.qa` output dirs:

- Add missing smoke spec only
- Extend config with `outputDir: '.qa/test-results'` if absent
- Do **not** upgrade Playwright version unless tests fail

## Install browsers in CI

```bash
npx playwright install --with-deps
```

Document in README if bootstrap added CI requirements.
