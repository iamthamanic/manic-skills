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

## Core catalog (JS/TS + shared)

| ID | Default depth | When (enable if) | Typical command |
|----|---------------|------------------|-----------------|
| `prettier` | standard | `.prettierrc*` or prettier in package.json | `npx prettier --check .` (or script) |
| `lint` | quick | eslint/biome/oxlint config or `lint` script; **or bootstrap on JS/TS** | `npm run lint` |
| `typecheck` | quick | `tsconfig*.json` / `typecheck` script / vue-tsc / astro check; **or bootstrap on JS/TS** | `npx tsc --noEmit` / `npm run typecheck` |
| `testRun` | standard | `test` / `test:unit` script (not watch) | `npm test -- --run` / `npm run test:unit` |
| `build` | standard | FE in scope + `build` script | `npm run build` |
| `viteBuild` | standard | `vite.config.*` and no Next | covered by `build` or `npx vite build` |
| `npmAudit` | standard (warn) / full (fail if yaml says) | npm lockfile present | `npm audit --audit-level=high` |
| `gitleaks` | standard | `gitleaks` on PATH or npx | `gitleaks detect --no-git -v` or diff-scoped |
| `sast` | full | `semgrep` available | `semgrep --config auto` (or project rules) |
| `shellcheck` | standard | `*.sh` in scope | `shellcheck <files>` |
| `snyk` | full | snyk script or token | `npm run snyk:test` |
| `i18nCheck` | never default | `testGate.enable: [i18n]` | project-specific |
| `checkMockData` | never default | explicit enable | project-specific |
| `complexity` | full optional | `testGate.optional` | eslint-plugin-complexity / configured |
| `architecture` | full optional | dependency-cruiser config | `depcruise` |
| `mutation` | never default | CI only | Stryker |
| `e2e` | full | `e2eCommand` in project.yaml | from yaml |

## Language catalog (non-JS / mixed)

| ID | Default depth | When | Typical command |
|----|---------------|------|-----------------|
| `ruff` | quick | Python in scope | `ruff check .` |
| `pyright` | quick | Python + pyrightconfig / `[tool.pyright]` | `pyright` |
| `mypy` | quick | Python + mypy config, no pyright | `mypy .` |
| `pytest` | standard | Python + pytest | `pytest` |
| `goVet` | quick | Go module (`go.mod`) | `go vet ./...` |
| `goTest` | standard | Go module | `go test ./...` |
| `staticcheck` | standard | Go + staticcheck available | `staticcheck ./...` |
| `cargoCheck` | quick | Rust (`Cargo.toml`) | `cargo check` |
| `cargoClippy` | quick | Rust | `cargo clippy -- -D warnings` (or project default) |
| `cargoTest` | standard | Rust | `cargo test` |
| `swiftLint` | quick | Swift + `.swiftlint.yml` or SPM | `swiftlint lint` / `swift build` |
| `swiftTest` | standard | Swift package / Xcode proj | `swift test` |
| `ktlint` | quick | Kotlin + ktlint config/Gradle | `./gradlew ktlintCheck` or `ktlint` |
| `gradleTest` | standard | Android/Kotlin Gradle | `./gradlew test` |
| `denoFmt` | standard | `deno.json*` in package | `deno fmt --check` |
| `denoLint` | quick | Deno package | `deno lint` |
| `denoCheck` | quick | Deno + TypeScript sources | `deno check <entry>` |
| `denoTest` | standard | Deno tests | `deno test` |
| `denoAudit` | full | deno backend | project-configured audit |

## Extra (not in shim) — project / ECC

| ID | Depth | When | Typical command |
|----|-------|------|-----------------|
| `checksBundle` | standard | `checksCommand` or `verify`/`checks` script | from `.qa/project.yaml` |
| `prismaValidate` | standard | `prisma/schema.prisma` | `npx prisma validate` (+ `generate` if AGENTS) |
| `securityGate` | standard | `backend/scripts/security-gate.sh` or AGENTS | `bash scripts/security-gate.sh --changed` |
| `typedStrict` | quick | TS/JS in scope (or yaml languages) | invoke `@typed-strict` |
| `secureByDefault` | quick | checklist active | RG probes from security-review skill |
| `rgAny` | quick | TS/JS touched + AGENTS forbids any | `rg ": any"|"as any"` on touched |
| `rgConsole` | quick | backend modules + AGENTS forbids console | `rg "console\.(log\|error\|warn)"` |
| `rgTailwindArbitrary` | quick | frontend + AGENTS Tailwind rule | `rg 'class[Nn]ame=.*\b[a-z-]+-\[[^\]]+\]'` |
| `rgCrossModule` | standard | backend modules touched | per AGENTS module isolation |
| `rgSecretsDiff` | quick | always | secrets patterns on diff / staged |

## Bootstrap recipes (JS/TS only)

When Step 5 detects missing **lint** or **typecheck** on a JS/TS package, provision **minimal** tooling, then re-run.

### Typecheck absent + `tsconfig*.json` present

```json
// package.json scripts
"typecheck": "tsc --noEmit"
```

- DevDep: `typescript` if missing (match existing major if lockfile hints).
- Prefer `vue-tsc --noEmit` / `astro check` when those frameworks are detected.
- No tsconfig at all on a TS-heavy tree → add minimal `"compilerOptions": { "strict": true, "noEmit": true, "moduleResolution": "bundler", "module": "ESNext", "target": "ES2022" }` only if sources are clearly TS; else document gap and FAIL required typecheck after asking… **No:** gate bootstraps minimal tsconfig for packages that already ship `.ts`/`.tsx` files.

### Lint absent

Prefer **one** of (first match wins):

1. **Biome** already partial → finish `biome.json` + `"lint": "biome check ."`
2. **Oxlint** already a dep → `"lint": "oxlint ."`
3. **ESLint flat** (default for Vite/React without Biome):

```js
// eslint.config.js — minimal
import js from '@eslint/js';
export default [js.configs.recommended];
```

```json
"lint": "eslint ."
```

DevDeps: `eslint`, `@eslint/js` (add `typescript-eslint` only if majority is `.ts`/`.tsx` — use recommended type-aware only when tsconfig already exists; keep config small).

4. **Deno package** → use `deno lint` (no npm eslint).

Do **not** add DaisyUI, Next, Prettier-as-lint-substitute, or multi-layer plugin stacks unless already present.

### After bootstrap

1. Update `.qa/project.yaml` if used:

```yaml
checksCommand: npm run checks   # or keep existing; ensure lint+typecheck reachable
testGate:
  profile: auto                 # or detected profile
  bootstrap:
    lint: true                  # set when this run provisioned lint
    typecheck: true
```

2. Prefer adding a composite script when helpful: `"checks": "npm run typecheck && npm run lint && npm test"` (only if `test` exists; else omit test).
3. Re-run lint/typecheck in the same invocation; record files touched under **Notes → Auto-provisioned**.

## Resolution notes

- **Prefer** package-manager scripts (`npm run`, `pnpm`, `cargo`, `go`) over raw tool CLIs when scripts exist.
- Monorepo: run per package root; bootstrap per in-scope JS/TS package that lacks gates.
- If `checksBundle` exits 0, still run `typedStrict` + `secureByDefault` + AGENTS RGs unless yaml says `testGate.bundleCoversRgs: true` (rare; prefer explicit).
- **Optional** checks that fail tool-not-found → **SKIP**, not FAIL (document reason).
- **Required** lint/typecheck on JS/TS: if missing → **bootstrap**, then run; if still missing/broken → **FAIL** (not SKIP).
- **Non-JS primary:** required checks come from language catalog; Node lint/tsc are out of scope (SKIP with reason “non-JS primary”), not FAIL.
