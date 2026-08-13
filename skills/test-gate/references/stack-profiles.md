# Test Gate — Stack Profiles

Used when `.qa/project.yaml` → `testGate.profile` is missing or `auto`.

Detection script: `../scripts/detect-stack.sh` (prints profile + signals + `PRIMARY_LANG` + `APP_KIND`).

## Profiles → default checks

| Profile | Signals | Default checks (intersect with catalog `when`) |
|---------|---------|--------------------------------------------------|
| `next` | `next.config.*`, `next` dep | lint, typecheck, build, testRun?, npmAudit, typedStrict, secureByDefault, rg* |
| `vite-react` | `vite.config.*` + react | lint, typecheck, build/viteBuild, testRun?, prettier?, npmAudit, typedStrict, … |
| `express-prisma` | express/fastify + `prisma/schema` | lint, typecheck, prismaValidate, securityGate?, testRun?, npmAudit, typedStrict, … |
| `monorepo` | workspaces or `frontend/`+`backend/` | per-package resolve; union of package profiles |
| `deno-supabase` | `deno.json` / `supabase/functions` | denoFmt, denoLint, denoCheck?, (+ FE profile if present) |
| `deno-only` | `deno.json*`, no npm app root | denoLint, denoCheck, denoFmt, denoTest?, secrets |
| `python-api` | `pyproject.toml` / `requirements.txt`, no major FE | ruff, pyright/mypy if present, pytest?, secrets |
| `go-api` | `go.mod` primary | goVet, goTest, staticcheck?, secrets |
| `rust-cli` | `Cargo.toml` primary (bin/lib) | cargoCheck, cargoClippy, cargoTest?, secrets |
| `swift-ios` | `Package.swift` / `*.xcodeproj` / `*.xcworkspace` | swiftLint?, swiftTest / xcodebuild if available, secrets |
| `kotlin-android` | `build.gradle*` + android/` or Kotlin multiplatform | ktlint?, gradleTest, secrets |
| `api-only` | Node API without FE framework | lint, typecheck, testRun?, npmAudit, typedStrict |
| `unknown` | none of the above | `checksCommand` or language-detected checks + secrets; typedStrict if TS |

## Application types (`APP_KIND`)

Detect from layout + deps (script prints `APP_KIND=`). Emphasize these required vs optional sets in the report **Language / app profile** section.

| APP_KIND | Examples | Emphasize required | Often optional |
|----------|----------|--------------------|----------------|
| `spa` | Vite/React, Next app router FE | build, typecheck, lint, unit/testRun if present, typedStrict, secrets | prettier, npmAudit, e2e |
| `api` | Express, Fastify, Go/Python API | lint/typecheck **or** language equiv (ruff/go vet/clippy), tests, security RG + securityGate/audit | sast, prettier |
| `cli` | Rust/Go/Node CLI | check/typecheck, tests, secrets | clippy/staticcheck as required when toolchain present |
| `mobile` | iOS Swift, Android Kotlin | platform lint + unit tests when tooling present, secrets | full device e2e |
| `game` | game engine / local engine pkg | build or unit for engine package, secrets; typedStrict if TS engine | full e2e |
| `data` | notebooks, pipelines | ruff/sqlfluff if present, secrets | full typecheck if untyped |
| `monorepo` | workspaces / fe+be | **per-package** profile checks | cross-package e2e |
| `unknown` | mixed/unclear | whatever detect finds + secrets | — |

**Iron rule:** recommended lists guide which checks to **enable**; PASS still requires every **enabled required** check to exit 0. Do not invent narrative review.

## Monorepo package hints

| Path | Treat as |
|------|----------|
| `frontend/`, `apps/web/`, `packages/ui/` | FE profile (next or vite from that package's config) |
| `backend/`, `apps/api/`, `server/` | BE (express-prisma if prisma at repo or package) |
| `supabase/functions/` | deno-supabase |
| `crates/`, `Cargo.toml` workspace members | rust-cli per crate in scope |
| `android/`, `ios/` | kotlin-android / swift-ios |

## Non-JS primary — behavior

1. Report `PRIMARY_LANG` and `APP_KIND` clearly.
2. Do **not** install or run eslint/tsc unless a JS/TS package is also in diff scope.
3. Map checks from this file + [check-catalog.md](check-catalog.md) language section.
4. SKIP Node-only checks with reason `non-JS primary`.
5. If language tooling is missing (e.g. no ruff on Python): prefer minimal bootstrap of **that** language’s standard linter when analogous to JS Step 5 (ruff for Python); otherwise SKIP with install hint — do not claim PASS on a silent no-op when AGENTS requires a named gate.

## Browo HR example (`browo-hr-monorepo`)

Explicit profile optional; auto `monorepo` + AGENTS §7 is enough:

- FE: `cd frontend && npx tsc --noEmit && npm run lint && npm run build`
- BE: `cd backend && npx prisma validate && npx tsc --noEmit && npm run lint` + `bash scripts/security-gate.sh --changed`
- Always: typed-strict, secure-by-default probes, AGENTS RG gates on touched paths

## Align with project-setup

`@project-setup` stack profiles live in `~/.claude/skills/project-setup/references/stack-profiles/`.
When writing `testGate.profile` on init, map:

| project-setup profile | testGate.profile |
|----------------------|------------------|
| `next` | `next` |
| `vite-react` | `vite-react` |
| `api-only` | `api-only` or `express-prisma` if prisma |
| `monorepo` | `monorepo` |
| `python` / `go` / `rust` | `python-api` / `go-api` / `rust-cli` |
| `cra` / other | `unknown` + checksCommand |
