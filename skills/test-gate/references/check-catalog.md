# Test Gate — Check Catalog

Deterministic checks only. Category `ai` is **never** enabled by `@test-gate`.

Inspired by shimwrappercheck registry; commands are stack-resolved (prefer package scripts).

## Always excluded

| ID | Reason |
|----|--------|
| `aiReview` | LLM — use `@review-ticket` |
| `explanationCheck` | LLM |
| `fallow` | Non-exit-code intelligence |
| `updateReadme` | Side effect, not a gate |

## Core catalog

| ID | Default depth | When (enable if) | Typical command |
|----|---------------|------------------|-----------------|
| `prettier` | standard | `.prettierrc*` or prettier in package.json | `npx prettier --check .` (or script) |
| `lint` | quick | eslint/biome config or `lint` script | `npm run lint` |
| `typecheck` | quick | `tsconfig*.json` or `typecheck` script | `npx tsc --noEmit` / `npm run typecheck` |
| `testRun` | standard | `test` / `test:unit` script (not watch) | `npm test -- --run` / `npm run test:unit` |
| `build` | standard | FE in scope + `build` script | `npm run build` |
| `viteBuild` | standard | `vite.config.*` and no Next | covered by `build` or `npx vite build` |
| `npmAudit` | standard (warn) / full (fail if yaml says) | lockfile present | `npm audit --audit-level=high` |
| `gitleaks` | standard | `gitleaks` on PATH or npx | `gitleaks detect --no-git -v` or diff-scoped |
| `sast` | full | `semgrep` available | `semgrep --config auto` (or project rules) |
| `ruff` | quick | Python in scope + ruff/pyproject | `ruff check .` |
| `shellcheck` | standard | `*.sh` in scope | `shellcheck <files>` |
| `denoFmt` | standard | `deno.json*` in package | `deno fmt --check` |
| `denoLint` | standard | deno backend | `deno lint` |
| `denoAudit` | full | deno backend | `deno info` / audit tooling if configured |
| `snyk` | full | snyk script or token | `npm run snyk:test` |
| `i18nCheck` | never default | `testGate.enable: [i18n]` | project-specific |
| `checkMockData` | never default | explicit enable | project-specific |
| `complexity` | full optional | `testGate.optional` | eslint-plugin-complexity / configured |
| `architecture` | full optional | dependency-cruiser config | `depcruise` |
| `mutation` | never default | CI only | Stryker |
| `e2e` | full | `e2eCommand` in project.yaml | from yaml |

## Extra (not in shim) — project / ECC

| ID | Depth | When | Typical command |
|----|-------|------|-----------------|
| `checksBundle` | standard | `checksCommand` or `verify`/`checks` script | from `.qa/project.yaml` |
| `prismaValidate` | standard | `prisma/schema.prisma` | `npx prisma validate` (+ `generate` if AGENTS) |
| `securityGate` | standard | `backend/scripts/security-gate.sh` or AGENTS | `bash scripts/security-gate.sh --changed` |
| `typedStrict` | quick | always | invoke `@typed-strict` |
| `secureByDefault` | quick | checklist active | RG probes from security-review skill |
| `rgAny` | quick | TS/JS touched + AGENTS forbids any | `rg ": any"|"as any"` on touched |
| `rgConsole` | quick | backend modules + AGENTS forbids console | `rg "console\.(log\|error\|warn)"` |
| `rgTailwindArbitrary` | quick | frontend + AGENTS Tailwind rule | `rg 'class[Nn]ame=.*\b[a-z-]+-\[[^\]]+\]'` |
| `rgCrossModule` | standard | backend modules touched | per AGENTS module isolation |
| `rgSecretsDiff` | quick | always | secrets patterns on diff / staged |

## Resolution notes

- **Prefer** `npm run <script>` over raw `npx` when script exists.
- Monorepo: run per package root (`frontend/`, `backend/`).
- If `checksBundle` exits 0, still run `typedStrict` + `secureByDefault` + AGENTS RGs unless yaml says `testGate.bundleCoversRgs: true` (rare; prefer explicit).
- Optional checks that fail tool-not-found → **SKIP**, not FAIL.
- Required checks that fail tool-not-found → FAIL with install hint (e.g. `tsc` missing but tsconfig present).
