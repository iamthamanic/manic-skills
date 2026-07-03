# Pipeline

Die ECC-Skills bilden eine zusammenhängende Pipeline von Feature-Idee bis gemergedem PR. `@ecc-runner` orchestriert sie pro Issue autonom (batch mode); die einzelnen Skills kannst du auch manuell aufrufen.

## Vollständige Pipeline

```
@feature-intake  →  @pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket  →  @ecc-check  →  @commit-pr-safe
                                                                                                                ↑
                                          @ecc-runner orchestriert das ganze pro Issue (batch mode)
```

## Fast Lane (ohne volle Pipeline)

Wenn du schnell codest und `@verify-ticket` / `@review-ticket` überspringst:

```
@audit-changes (quick | standard)  →  weiter coden
@audit-changes (standard)          →  optional vor Commit
@ecc-check                         →  Pflicht vor PR / Ship
```

`@audit-changes` ist **kein** Ersatz für `@ecc-check`. Exit: `CLEAN` / `WARN` / `BLOCK` (weiterarbeiten bei WARN erlaubt). Scope: uncommitted, since-commit, PR, oder Pfad/Keyword (z. B. „time management“).

Nach PR-Erstellung:

```
@commit-pr-safe  →  CI läuft  →  @babysit (hält merge-ready)  →  @pr-merge-safe (review + merge wenn green)
```

## Phasen im Detail

### Phase 1 — Intake: `@feature-intake`

Analysiert PRD/Konzept gegen das Repo, stellt UI/Runtime-Fragen, schreibt Epic-Design nach `.qa/design/`, zerlegt in geordnete GitHub-Issue-Drafts unter `.qa/intake/`. Issues werden **erst nach User-OK** erstellt, dann an `@ecc-runner` übergeben.

Trigger: `feature-intake`, `neues feature`, `PRD zerlegen`, `epic intake`.

Output: `.qa/design/<epic>.md`, `.qa/intake/*.json` (Issue-Drafts), GitHub Issues.

### Phase 2 — Solution Design: `@pingpong-solution`

Sokratisches Discovery, Domain-Expert-Optionen mit Evidenz (inkl. Ponytail-YAGNI-Option), Codebase-Fit, Cross-Domain-Checks (KISS, SOLID, DRY, Security, UI/UX, Scaling), Confidence-Rubrik. Schreibt `.qa/design/<slice>.md` für `@implement`.

Trigger: `pingpong-solution`, `how to integrate`, `rough idea`.

Wird aufgerufen: für Issues mit Label `needs-design`, oder manuell vor `@implement`.

Output: `.qa/design/<slug>.md`.

### Phase 3 — Implementation: `@implement`

Liest `.qa/design` von `pingpong-solution`, auto-generiert `.qa/acceptance/<slug>.md` **vor** Code-Änderungen, minimale Diffs, Ponytail-Ladder, Security, Validation. Wendet Helper-Skills inline an:

- `@foundations` — neue Module, Adapter, Refactor, unklare Boundaries
- `@search-first` — vor neuen Utils/Deps/Abstractions
- `@documentation-lookup` — bei neuen Library/API/MCP-Integrations
- `@security-review` — bei Auth, UGC, Storage, P2P, Secrets
- `@strategic-compact` — bei großem Diff / langer Session

Trigger: nach `@pingpong-solution`, oder manuell für Features/Bugfixes/Refactors.

Output: Code-Änderungen + `.qa/acceptance/<slug>.md`.

### Phase 4 — Verify Ticket: `@verify-ticket`

Technische Verifikation: läuft Project-Checks (`npm run verify`), validiert Diff gegen Acceptance-Kriterien aus `.qa/acceptance/<slug>.md`, bestätigt Build und Tests.

Trigger: nach `@implement`, `verify ticket`, `validate implementation`.

### Phase 5 — Verify UI: `@verify-ui` (conditional)

UI/UX-Verifikation für Projekte mit UI-Änderungen: entdeckt Kontext aus AGENTS.md und Styleguides, bootstrapped Playwright nur wenn fehlt, läuft e2e-Szenarien mit Screenshots und Edge Cases.

Trigger: `verify UI`, `smoke test`, `screenshot proof`, `e2e check`. Wird empfohlen nach `@implement`, wenn UI-Dateien (`src/components|pages|hooks`) im Diff sind.

### Phase 6 — Review: `@review-ticket`

Statische Code-Quality-Review nach `@verify-ticket` und `@verify-ui`: Architektur-Fit, Maintainability, Security-Hotspots, Diff-Scope vs Acceptance. Nutzt `@review-bugbot` und `@review-security` subagents bei Bedarf. Verdict: `ACCEPT` oder `CHANGES_REQUESTED`.

Trigger: `review ticket`, `code review ticket`, `pre-PR review`.

### Fast Lane — Audit: `@audit-changes`

Diff-scoped Fast-Lane-Audit für Security, Wartbarkeit, SOLID/KISS/DRY — ohne Playwright-Pflicht.

Trigger: `audit changes`, `quick audit`, `check changes`, `audit since commit`, `audit time management`.

Depth: `quick` (default, diff-scoped tsc/lint) · `standard` (volle Package-Checks + Review lite) · `full` (+ optional UI/Acceptance).

Exit: `CLEAN` / `WARN` / `BLOCK`. Vor PR trotzdem `@ecc-check`.

### Phase 7 — ECC Check: `@ecc-check`

Quality-Gate-Loop für das aktuelle Ticket. Läuft Phasen A–F in Reihenfolge:

```
Phase A: Deterministic checks (npm run verify)
Phase B: @verify-ticket (optional, wenn acceptance file existiert)
Phase C: @review-ticket (bis ACCEPT)
Phase D: AgentShield (npx ecc-agentshield scan --path .cursor)
Phase E: @verify-ui (conditional, wenn UI im Diff)
Phase F: Report READY | BLOCKED
```

Exit-States: `READY` → nächste Phase (`@commit-pr-safe`), `BLOCKED` → Blocker melden, nicht committen/pushen.

Retry-Limits: Phase A 3 Runden, Phase C 2 Runden, Phase D 2 Runden, gleicher Root-Error 2 Runden → BLOCKED.

Trigger: `ecc-check`, `/ecc-check`, `merge-ready`, `quality gate`. **Vor** jedem Ship.

### Phase 8 — Ship: `@commit-pr-safe` oder `@commit-push-safe`

Liest Project-Rules (AGENTS.md, README, CONTRIBUTING), validiert non-main Target-Branch, inspiziert Git-State, scannt Diff nach Secrets, läuft AgentShield auf `.cursor/`, synced README living sections, committet, pusht auf approved non-main Branch, öffnet PR.

`@commit-push-safe`: gleich, aber ohne PR (nur Commit + Push).

Trigger: `commit-pr-safe`, `ship PR`, `open PR`, `merge-ready ship` (PR); `commit-push-safe`, `push safely` (Push-only).

### Phase 9 — Merge: `@pr-merge-safe`

Reviewt offenen PR mit `@verify-ticket`, `@review-ticket`, `@ecc-check`, `@babysit`. Merged, wenn alle Gates passieren und der User explizit `merge` sagt.

Trigger: `pr-merge-safe`, `/pr-merge-safe`, `review and merge`, `merge PR if green`.

## Orchestrierung: `@ecc-runner`

Autonomer GitHub-Issue-Runner. Bootstrapped Labels, baut Queue aus offenen Issues, arbeitet jedes Issue mit der vollen Pipeline (implement → verify → review → PR) ab — ohne per-step Prompts.

Modi:

| Modus | Trigger | Verhalten |
|-------|---------|----------|
| Batch (default) | `@ecc-runner`, `issues abarbeiten` | Alle Phasen pro Issue → nächstes Issue → ein finaler Report |
| Step | `ecc-runner step` | Nur eine Phase, dann stop und summarize |
| Status | `ecc-runner status` | Survey + State, keine Code-Änderungen |

Pro-Projekt-Konfiguration in `.qa/runner-profile.yaml` (stack-spezifische Helper-Routing), `.qa/project.yaml` (checksCommand, acceptanceDir), `.qa/queue/state.json` (Queue-State).

## Project-Konfiguration

Die Pipeline liest pro Projekt:

- `.qa/project.yaml` → `checksCommand`, `checksSnippet`, `acceptanceDir`
- `.qa/runner-profile.yaml` → `checksSnippet`, Retry-Hints
- `AGENTS.md` → Branch-Rules, Stack-Defaults
- `.qa/acceptance/<slug>.md` → Acceptance-Vertrag (von `@implement` auto-generiert)
- `.qa/design/<slug>.md` → Design-Vertrag (von `@pingpong-solution`)

Default checks command wenn unset: `npm run verify`.