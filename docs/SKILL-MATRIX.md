# Skill Matrix

Kompakte Referenz aller Skills im Repo, gruppiert nach Systembasis. Vollständige Beschreibungen in den jeweiligen `skills/<name>/SKILL.md`. Windsurf-Kompatibilität: ✅ voll · ⚠️ mit Einschränkung — siehe [`WINDSURF-COMPATIBILITY.md`](WINDSURF-COMPATIBILITY.md).

## ECC (Engineering-Disziplin-Suite)

| Skill | Trigger | Zweck | Wind | Abhängigkeiten |
|-------|---------|-------|------|----------------|
| `@ecc-check` | `ecc-check`, `/ecc-check`, `merge-ready`, `quality gate` | Quality-Gate-Loop (verify + review + AgentShield) bis READY/BLOCKED | ⚠️ | `npm run verify`, `@review-ticket`, `npx ecc-agentshield`, `@verify-ui` (conditional) |
| `@ecc-runner` | `ecc-runner`, `/ecc-runner`, `issues abarbeiten`, `issue queue` | Autonomer GitHub-Issue-Queue-Runner (batch/step/status) | ⚠️ | `@implement`, `@ecc-check`, `@commit-pr-safe`, `gh` CLI |
| `@feature-intake` | `feature-intake`, `/feature-intake`, `neues feature`, `PRD zerlegen`, `epic intake` | Epic → Design → Issue-Drafts, nur nach User-OK | ✅ | `.qa/design/`, `.qa/intake/`, `@ecc-runner` |
| `@pingpong-solution` | `pingpong-solution`, `how to integrate`, `rough idea` | Pre-Implementation Solution-Ping-Pong, `.qa/design` für `@implement` | ✅ | `@implement`, `@ponytail` (YAGNI-Option) |
| `@implement` | nach `@pingpong-solution`, `implement` | Implementation Contract, Acceptance-Auto-Gen, Ponytail-Ladder | ⚠️ | `@foundations`, `@search-first`, `@documentation-lookup`, `@security-review`, `@strategic-compact` |
| `@foundations` | `foundations`, `information hiding`, `leaky abstraction`, `distributed monolith` | SE-Referenz (Parnas, Liskov, Hoare, Dijkstra, Brooks) — Reference Skill | ✅ | — |
| `@verify-ticket` | `verify ticket`, `validate implementation`, nach `@implement` | Technische Verifikation gegen Acceptance | ✅ | `.qa/acceptance/*.md`, `npm run verify` |
| `@verify-ui` | `verify UI`, `smoke test`, `screenshot proof`, `e2e check` | UI/UX-Verifikation (Playwright, Screenshots, Edge Cases) | ✅ | Browser, AGENTS.md |
| `@review-ticket` | `review ticket`, `code review ticket`, `pre-PR review` | Code-Quality-Review, `ACCEPT`/`CHANGES_REQUESTED` | ⚠️ | `@review-bugbot`, `@review-security` (Cursor-subagents) |
| `@commit-pr-safe` | `commit-pr-safe`, `/commit-pr-safe`, `ship PR`, `open PR`, `merge-ready ship` | Commit + Push + PR auf non-main, nach Quality Gate | ✅ | `@ecc-check` READY, `npx ecc-agentshield` |
| `@commit-push-safe` | `commit-push-safe`, `push safely`, `ship without PR` | Commit + Push ohne PR, README-Sync, Secret-Scan | ✅ | `@ecc-check` READY |
| `@pr-merge-safe` | `pr-merge-safe`, `/pr-merge-safe`, `review and merge`, `merge PR if green` | PR reviewen + mergen wenn alle Gates green | ⚠️ | offener PR, `@verify-ticket`, `@review-ticket`, `@ecc-check`, `@babysit` |
| `@verification-loop` | `verification-loop` | Pre-PR Full Gate (build, typecheck, lint, tests, security) | ✅ | AGENTS.md checks command |
| `@ecccheck` ⚠️ | — | **deprecated** → `@ecc-check` | — | — |
| `@prepare-deploy-pr` ⚠️ | — | **deprecated** → `@commit-pr-safe` | — | — |

## Ponytail (YAGNI/Minimalismus)

| Skill | Trigger | Zweck | Wind |
|-------|---------|-------|------|
| `@ponytail` | `ponytail`, `be lazy`, `yagni`, `do less`, `shortest path` | Lazy-senior-dev-Modus, YAGNI-Ladder, Intensitätslevel (`lite`/`full`/`ultra`) | ✅ |
| `@ponytail-review` | `review for over-engineering`, `what can we delete`, `/ponytail-review` | Review nur auf Over-Engineering | ✅ |
| `@ponytail-audit` | `audit this codebase`, `find bloat`, `/ponytail-audit` | Whole-Repo-Audit auf Over-Engineering, ranked report | ✅ |
| `@ponytail-debt` | `ponytail debt`, `what did ponytail defer`, `ponytail ledger` | `ponytail:`-Kommentare im Code → Debt-Ledger | ✅ |
| `@ponytail-gain` | `ponytail gain`, `what does ponytail save`, `/ponytail-gain` | Ponytail-Impact-Scoreboard (less code, less cost, more speed) | ✅ |
| `@ponytail-help` | `ponytail help`, `how do I use ponytail`, `/ponytail-help` | Quick-Reference-Card für alle Ponytail-Modi | ✅ |

## Standalone

| Skill | Trigger | Zweck | Wind | Abhängigkeiten |
|-------|---------|-------|------|----------------|
| `@project-setup` | `project setup`, `bootstrap repo`, `scaffold project files` | Repo-Bootstrap (PRD, AGENTS.md, README, `.qa/`, styleguide) | ✅ | — |
| `@mine-stars` | `mine-stars`, `check my stars`, `starred repos`, `prior art from stars` | GitHub-Stars durchsuchen für Patterns/Ideen | ✅ | GitHub API |
| `@search-first` | `search-first` | Research-before-coding, invokes researcher agent | ⚠️ | researcher subagent (Cursor-spezifisch) |
| `@documentation-lookup` | `documentation-lookup`, Framework-Names | Library-Docs via Context7 MCP statt Training-Data | ✅ | context7 MCP |
| `@security-review` | `security-review` | Security-Checklist (Auth, Input, Secrets, Payments) | ✅ | — |
| `@strategic-compact` | `strategic-compact` | Kontext-Kompaktion an logischen Intervallen | ✅ | — |
| `@save-prompts-inject` | `save prompt`, `use prompt`, `inject prompt`, `list prompts`, `delete prompt` | Prompts in `~/.cursor/prompts/` speichern/injecten | ⚠️ | `~/.cursor/prompts/` (Cursor-Pfad hardcoded) |

## Nach Systembasis

| Basis | Skills | Count |
|-------|--------|-------|
| ECC | `ecc-check`, `ecc-runner`, `feature-intake`, `pingpong-solution`, `implement`, `foundations`, `verify-ticket`, `verify-ui`, `review-ticket`, `commit-pr-safe`, `commit-push-safe`, `pr-merge-safe`, `verification-loop`, `ecccheck` (deprecated), `prepare-deploy-pr` (deprecated) | 15 |
| Ponytail | `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` | 6 |
| Standalone | `project-setup`, `mine-stars`, `search-first`, `documentation-lookup`, `security-review`, `strategic-compact`, `save-prompts-inject` | 7 |
| **Total** | | **28** |

## Nach Windsurf-Kompatibilität

| Status | Count | Skills |
|--------|-------|--------|
| ✅ voll kompatibel | 19 | `feature-intake`, `pingpong-solution`, `foundations`, `verify-ticket`, `verify-ui`, `commit-pr-safe`, `commit-push-safe`, `verification-loop`, `project-setup`, `mine-stars`, `documentation-lookup`, `security-review`, `strategic-compact`, `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` |
| ⚠️ mit Einschränkung | 7 | `ecc-check`, `ecc-runner`, `implement`, `review-ticket`, `pr-merge-safe`, `search-first`, `save-prompts-inject` |
| ❌ inkompatibel | 0 | — |
| deprecated (nicht gezählt) | 2 | `ecccheck`, `prepare-deploy-pr` |