# ECC Stack

ECC ist ein Agent-Framework / https://github.com/affaan-m/ecc — es ist eine Suite die Engineering-Disziplin durchsetzt: deterministische Checks, Acceptance-Verträge, Code-Review-Gate, AgentShield, sicheres Ship. Die Skills referenzieren sich gegenseitig und teilen sich die Pipeline.

## Was ECC bedeutet

ECC steht für eine Sammlung zusammenhängender Skills unter `~/.cursor/skills/`, die zusammen einen Qualitäts- und Workflow-Stack bilden. Es gibt keine `ecc`-Binary, kein npm-Paket, keine externe Abhängigkeit. Die "Systembasis" ist reiner Skill-Markdown, der Tools wie `npm run verify`, `npx ecc-agentshield`, `gh` (GitHub CLI) und subagents (`@review-bugbot`, `@review-security`) orchestriert.

## Skills im ECC-Stack

### Kern-Pipeline

| Skill | Rolle |
|-------|-------|
| `@feature-intake` | Epic → Design → Issues, nur nach User-OK |
| `@pingpong-solution` | Pre-Implementation Solution-Ping-Pong, `.qa/design` |
| `@implement` | Implementation Contract, Acceptance-Auto-Gen, wendet Helper inline an |
| `@verify-ticket` | Technische Verifikation gegen Acceptance (`@test-gate` + AC) |
| `@composition-gate` | Hop-Ketten-Bedeutung; CLEAR/SKIPPED/FLAGGED — FLAGGED muss gefixt werden |
| `@verify-ui` | UI/UX-Verifikation (Playwright, Screenshots) |
| `@review-ticket` | Code-Quality-Review, `ACCEPT` / `CHANGES_REQUESTED` (braucht composition-gate CLEAR/SKIPPED) |
| `@test-gate` | Deterministische Tools/Scripts (Exit-Code) — Phase A von `@ecc-check` |
| `@ecc-check` | Quality-Gate-Loop (A–F inkl. B2 composition-gate), `READY` / `BLOCKED` (A = `@test-gate`) |
| `@commit-pr-safe` | Commit + Push + PR auf non-main (composition-gate Proof oder Run) |
| `@commit-push-safe` | Commit + Push ohne PR |
| `@pr-merge-safe` | PR reviewen + mergen wenn green (Phase 1b = composition-gate) |

### Fast Lane

| Skill | Rolle |
|-------|-------|
| `@audit-changes` | Diff-scoped Audit (Security, SOLID, KISS, DRY) — `CLEAN`/`WARN`/`BLOCK`, kein Ship-Gate |

### Orchestrierung

| Skill | Rolle |
|-------|-------|
| `@ecc-runner` | Autonomer Issue-Queue-Runner, batch mode |
| `@ecc-runner-loop` | Queue + Merge-Loop (composed) |
| `@babysit` | Hält PR merge-ready, triaged Comments/CI |
| `@foundations` | SE-Referenz (Parnas, Liskov, Hoare, Dijkstra, Brooks) — Reference Skill, kein Pipeline-Step |
| `@test-gate` | Shared deterministic runner (prefer over ad-hoc verify) |
| `@verification-loop` | Legacy Pre-PR checklist → prefer `@test-gate` / `@ecc-check` |
| `@typed-strict` | No type escape hatches; invoked by `@test-gate` |

### Helper (inline in `@implement`)

| Skill | Wann angewendet |
|-------|-----------------|
| `@search-first` | Vor neuen Utils, Deps, Abstractions |
| `@documentation-lookup` | Bei neuen Library/API/MCP-Integrations |
| `@security-review` | Bei Auth, UGC, Storage, P2P, Secrets |
| `@strategic-compact` | Bei großem Diff / langer Session |
| `@foundations` | Bei neuen Modulen, Adaptern, unklaren Boundaries |

### Deprecated

| Skill | Nachfolger |
|-------|------------|
| `@ecccheck` | `@ecc-check` |
| `@prepare-deploy-pr` | `@commit-pr-safe` |

## Externe Abhängigkeiten

ECC-Skills orchestrieren externe Tools, die im Projekt vorhanden sein müssen:

- **`@test-gate`** — führt projektbezogene Scripts aus (`checksCommand`, lint, tsc, prisma, RG-Probes); Exit-Code = Wahrheit
- **`npm run verify`** / `checksCommand` in `.qa/project.yaml` — oft vom test-gate aufgerufen
- **`npx ecc-agentshield`** — scannt `.cursor/`-Agenten-Konfiguration auf Security/Quality
- **`gh` (GitHub CLI)** — für `@ecc-runner`, `@commit-pr-safe`, `@pr-merge-safe`, `@babysit`
- **`@review-bugbot` / `@review-security`** — subagents (offizielle Cursor-Skills aus `~/.cursor/skills-cursor/`)
- **Playwright** — für `@verify-ui` (wird bei Bedarf automatisch gebootstrappt)
- **Context7 MCP** — für `@documentation-lookup`

Fehlt ein Tool, reportet der Skill den Blocker — anstatt zu improvisieren.

## Pro-Projekt-Konfiguration

ECC-Skills sind maschinenlokal (`~/.cursor/skills/`), aber ihr Verhalten wird **pro Projekt** konfiguriert:

| Datei | Inhalt |
|-------|--------|
| `.qa/project.yaml` | `testGate`, `checksCommand`, `checksSnippet`, `acceptanceDir`, `typedStrict`, `security` |
| `.qa/runner-profile.yaml` | `checksSnippet`, Retry-Hints, stack-spezifische Helper-Routing |
| `AGENTS.md` | Branch-Rules, Stack-Defaults, Repo-Hygiene |
| `.qa/acceptance/<slug>.md` | Acceptance-Vertrag (von `@implement` auto-generiert) |
| `.qa/design/<slug>.md` | Design-Vertrag (von `@pingpong-solution`) |
| `.qa/queue/state.json` | Queue-State für `@ecc-runner` |
| `.qa/runs/*.md` | Run-Logs (optional) |

Default: `@test-gate` mit `checksCommand` oder Auto-Detect; oft `npm run verify`.

## Was ECC nicht ist

- Kein Appwrite-Feature, kein Cloud-Service
- Kein npm-Paket, das man installiert
- Keine eigenständige CLI
- Nicht an den Cursor-Account gebunden (maschinenlokal)
- Nicht projektlokal (gilt für alle Projekte auf der Maschine, Konfiguration pro Projekt)

## Beziehung zu anderen Systemen

| System | Beziehung zu ECC |
|--------|-------------------|
| **Ponytail** | `@implement` wendet die Ponytail-Ladder inline an; `@ponytail-review` ergänzt `@review-ticket` um Over-Engineering-Perspektive |
| **Standalone-Skills** | `@search-first`, `@documentation-lookup`, `@security-review`, `@strategic-compact` sind Helper, die `@implement` inline aufruft |
| **Offizielle Cursor-Skills** | `@review-bugbot`, `@review-security` (subagents) werden von `@review-ticket` aufgerufen; `@babysit` ist Teil der ECC-Pipeline nach PR |
