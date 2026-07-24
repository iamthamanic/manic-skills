# Test Gate — Stack Profiles

Used when `.qa/project.yaml` → `testGate.profile` is missing or `auto`.

Detection script: `../scripts/detect-stack.sh` (prints profile + signals).

## Profiles → default checks

| Profile | Signals | Default checks (intersect with catalog `when`) |
|---------|---------|--------------------------------------------------|
| `next` | `next.config.*`, `next` dep | lint, typecheck, build, testRun?, npmAudit, typedStrict, secureByDefault, rg* |
| `vite-react` | `vite.config.*` + react | lint, typecheck, build/viteBuild, testRun?, prettier?, npmAudit, typedStrict, … |
| `express-prisma` | express/fastify + `prisma/schema` | lint, typecheck, prismaValidate, securityGate?, testRun?, npmAudit, typedStrict, … |
| `monorepo` | workspaces or `frontend/`+`backend/` | per-package resolve; union of package profiles |
| `deno-supabase` | `deno.json` / `supabase/functions` | denoFmt, denoLint, (+ FE profile if present) |
| `python-api` | `pyproject.toml` / `requirements.txt`, no major FE | ruff, pyright/mypy if present, typedStrict, secrets |
| `api-only` | Node API without FE framework | lint, typecheck, testRun?, npmAudit, typedStrict |
| `unknown` | none of the above | `checksCommand` or any of lint/test/build scripts that exist + typedStrict + secrets |

## Monorepo package hints

| Path | Treat as |
|------|----------|
| `frontend/`, `apps/web/`, `packages/ui/` | FE profile (next or vite from that package's config) |
| `backend/`, `apps/api/`, `server/` | BE (express-prisma if prisma at repo or package) |
| `supabase/functions/` | deno-supabase |

## Browo HR example (`browo-hr-monorepo`)

Explicit profile optional; auto `monorepo` + AGENTS §7 is enough:

- FE: `cd frontend && npx tsc --noEmit && npm run lint && npm run build`
- BE: `cd backend && npx prisma validate && npx tsc --noEmit && npm run lint` + `bash scripts/security-gate.sh --changed`
- Always: typed-strict, secure-by-default probes, AGENTS RG gates on touched paths

## Align with project-setup

`@project-setup` stack profiles live in `~/.cursor/skills/project-setup/references/stack-profiles/`.
When writing `testGate.profile` on init, map:

| project-setup profile | testGate.profile |
|----------------------|------------------|
| `next` | `next` |
| `vite-react` | `vite-react` |
| `api-only` | `api-only` or `express-prisma` if prisma |
| `monorepo` | `monorepo` |
| `cra` / other | `unknown` + checksCommand |
