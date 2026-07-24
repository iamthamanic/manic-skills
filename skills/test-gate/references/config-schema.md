# Test Gate — Config Schema (`.qa/project.yaml`)

Optional block. If missing, `@test-gate` auto-detects.

```yaml
# Existing keys used by test-gate:
checksCommand: npm run verify      # primary bundle (standard+)
checksSnippet: npm run lint        # optional faster bundle
e2eCommand: npm run test:e2e       # full depth only

typedStrict:
  languages: [typescript]

security:
  checklist: secure-by-default     # enables RG probes

testGate:
  profile: auto                    # auto | next | vite-react | express-prisma | monorepo | deno-supabase | python-api | api-only | browo-hr-monorepo | unknown
  depthDefault: standard           # quick | standard | full
  runner: scripts                  # scripts | shim (shim => MCP/CLI noAiReview only)
  bundleCoversRgs: false           # if true, skip AGENTS RGs when checksCommand passes (not recommended)

  packages:
    frontend:
      root: frontend
      checks: [lint, typecheck, build, rgTailwindArbitrary, rgSecretsDiff]
    backend:
      root: backend
      checks: [lint, typecheck, prismaValidate, securityGate, rgAny, rgConsole, rgCrossModule]

  always:
    - typedStrict
    - secureByDefault
    - rgSecretsDiff

  optional:                        # standard+ may SKIP if tool missing; full may require
    - prettier
    - gitleaks
    - sast
    - npmAudit

  never:
    - aiReview
    - explanationCheck
    - fallow
    - updateReadme
    - mutation

  # Optional command overrides (win over catalog defaults)
  commands:
    typecheck.frontend: "cd frontend && npx tsc --noEmit -p tsconfig.json"
    typecheck.backend: "cd backend && npx tsc --noEmit"
    lint.frontend: "cd frontend && npm run lint"
    lint.backend: "cd backend && npm run lint"
    prismaValidate: "cd backend && npx prisma validate"
    securityGate: "cd backend && bash scripts/security-gate.sh --changed"
```

## Minimal viable (any project)

```yaml
checksCommand: npm run checks   # or verify
security:
  checklist: secure-by-default
typedStrict:
  languages: [typescript]       # from detect-languages.sh
# testGate omitted → auto
```

## Init / audit (`@project-setup`)

On init or audit:

1. Ensure `checksCommand` points at a real script or document gap.
2. If `testGate` missing, write:

```yaml
testGate:
  profile: auto
  depthDefault: standard
  runner: scripts
  always: [typedStrict, secureByDefault, rgSecretsDiff]
  never: [aiReview, explanationCheck, fallow, updateReadme, mutation]
```

3. Set `profile` to detected stack when confident (`next`, `monorepo`, …).
4. Never enable AI checks under `testGate`.
