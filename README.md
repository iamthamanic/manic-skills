# Manic Skills

Persönliche Agent-Skills für **Cursor** und **Windsurf**, maschinenlokal gespiegelt via Git. Portabel, account-unabhängig. Klone das Repo, führe `scripts/install.sh` aus, und alle Skills sind auf der neuen Maschine aktiv.

## Was sind Skills?

Markdown-Dateien (`SKILL.md`) mit YAML-Frontmatter (`name`, `description`, optional `disable-model-invocation`, `argument-hint`, `license`). Der Skill-Body ist Markdown mit Anweisungen für den Agent. Beide Tools — Cursor und Windsurf — verwenden praktisch dasselbe Format:

| Aspekt | Cursor | Windsurf |
|--------|--------|----------|
| Skill-Datei | `SKILL.md` mit YAML-Frontmatter | `SKILL.md` mit YAML-Frontmatter |
| Pflicht-Felder | `name`, `description` | `name`, `description` |
| Invocation | Model entscheidet oder `@skill-name` | Model entscheidet oder `@skill-name` |
| Progressive Disclosure | nur `name` + `description` bis Invocation | nur `name` + `description` bis Invocation |
| Globaler Pffad | `~/.cursor/skills/<name>/` | `~/.codeium/windsurf/skills/<name>/` |
| Workspace-Pfad | `<workspace>/.cursor/skills/` | `<workspace>/.windsurf/skills/` |

Frontmatter-Felder, die nur Cursor kennt (`disable-model-invocation`, `argument-hint`), werden von Windsurf ignoriert — sie stören nicht, aber Windsurf auto-invoked dann auch Skills, die in Cursor bewusst manuell-only waren. Details dazu in [`docs/WINDSURF-COMPATIBILITY.md`](docs/WINDSURF-COMPATIBILITY.md).

Dieses Repo enthält **nur** custom Skills aus `~/.cursor/skills/`. Offizielle Cursor-Skills (`~/.cursor/skills-cursor/`), Codex-Skills (`~/.codex/skills/`), Agent-Harness-Skills (`~/.agents/skills/`) und projektlokale Skills gehören nicht hierher — sie haben eigene Speicherorte und Sync-Mechanismen.

## Quick install

**Cursor (default):**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh
```

**Windsurf:**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --windsurf
```

**Beide Tools parallel:**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --all
```

`install.sh` legt Symlinks von `<tool-skills-dir>/<name>` → `~/repos/manic-skills/skills/<name>`.
Danach reicht `git pull`, um alle Skills in beiden Tools zu aktualisieren — ein Repo, zwei Tools, ein Update.

Siehe [`INSTALL.md`](INSTALL.md) für alternative Installationsmethoden (copy, direkter Klon, Updates, Deinstallation) und [`docs/WINDSURF-COMPATIBILITY.md`](docs/WINDSURF-COMPATIBILITY.md) für detaillierte Kompatibilitäts-Hinweise.

## Skill-Index

Vollständige Tabelle aller Skills im Repo. **Basis** bedeutet das System, auf dem der Skill aufbaut: ECC (eigene Quality-Gate-Suite), Ponytail (YAGNI/Minimalismus-Werkzeuge) oder Standalone. **Wind** zeigt die Windsurf-Kompatibilität: ✅ voll, ⚠️ mit Einschränkung, ❌ nicht kompatibel.

| Skill | Zweck | Basis | Wind | Trigger | Abhängigkeiten |
|-------|-------|-------|------|---------|----------------|
| `@ecc-check` | Quality-Gate-Loop: verify + review + AgentShield bis READY | ECC | ⚠️ | `ecc-check`, `/ecc-check`, `merge-ready`, `quality gate` | `npm run verify`, `@review-ticket`, `npx ecc-agentshield` |
| `@ecc-runner` | Autonomer GitHub-Issue-Queue-Runner | ECC | ⚠️ | `ecc-runner`, `/ecc-runner`, `issues abarbeiten`, `issue queue` | `@implement`, `@ecc-check`, `@commit-pr-safe`, `gh` CLI |
| `@feature-intake` | Epic → Design → Issues, nur nach User-OK | ECC | ✅ | `feature-intake`, `/feature-intake`, `neues feature`, `PRD zerlegen`, `epic intake` | `.qa/design/`, `.qa/intake/`, `@ecc-runner` |
| `@pingpong-solution` | Pre-Implementation Solution-Ping-Pong, `.qa/design` für `@implement` | ECC | ✅ | `pingpong-solution`, `how to integrate` | `@implement` |
| `@implement` | Implementation Contract, Acceptance-Auto-Gen, Ponytail-Ladder, Security | ECC | ⚠️ | nach `@pingpong-solution` | `@foundations`, `@search-first`, `@security-review`, `@strategic-compact` |
| `@foundations` | SE-Referenz (Parnas, Liskov, Hoare, Dijkstra, Brooks) | ECC | ✅ | `foundations`, `information hiding`, `leaky abstraction`, `distributed monolith` | — |
| `@verify-ticket` | Technische Verifikation gegen Acceptance | ECC | ✅ | nach `@implement`, `verify ticket`, `validate implementation` | `.qa/acceptance/*.md` |
| `@verify-ui` | UI/UX-Verifikation (Playwright, Screenshots, Edge Cases) | ECC | ✅ | `verify UI`, `smoke test`, `screenshot proof`, `e2e check` | Browser, AGENTS.md |
| `@review-ticket` | Code-Quality-Review (Architektur, Security, Diff-Scope) | ECC | ⚠️ | `review ticket`, `code review ticket`, `pre-PR review` | `@review-bugbot`, `@review-security` (Cursor-subagents) |
| `@commit-pr-safe` | Commit + Push + PR auf nicht-main, nach Quality Gate | ECC | ✅ | `commit-pr-safe`, `/commit-pr-safe`, `ship PR`, `open PR`, `merge-ready ship` | `@ecc-check` READY |
| `@commit-push-safe` | Commit + Push (kein PR), README-Sync, Secret-Scan | ECC | ✅ | `commit-push-safe`, `push safely`, `ship without PR` | `@ecc-check` READY |
| `@pr-merge-safe` | PR reviewen + mergen, wenn alle Gates green | ECC | ⚠️ | `pr-merge-safe`, `/pr-merge-safe`, `review and merge`, `merge PR if green` | offener PR, `@verify-ticket`, `@review-ticket`, `@ecc-check`, `@babysit` |
| `@verification-loop` | Pre-PR Full Gate (build, typecheck, lint, tests, security) | ECC | ✅ | `verification-loop` | AGENTS.md checks command |
| `@project-setup` | Repo-Bootstrap (PRD, AGENTS.md, README, `.qa/`, styleguide) | Standalone | ✅ | `project setup`, `bootstrap repo`, `scaffold project files` | — |
| `@mine-stars` | GitHub-Stars durchsuchen für Patterns/Ideen | Standalone | ✅ | `mine-stars`, `check my stars`, `starred repos`, `prior art from stars` | GitHub API |
| `@search-first` | Research-before-coding, invokes researcher agent | Standalone | ⚠️ | `search-first` | researcher subagent (Cursor-spezifisch) |
| `@documentation-lookup` | Library-Docs via Context7 MCP statt Training-Data | Standalone | ✅ | `documentation-lookup`, Framework-Names | context7 MCP |
| `@security-review` | Security-Checklist für Auth, Input, Secrets, Payments | Standalone | ✅ | `security-review` | — |
| `@strategic-compact` | Kontext-Kompaktion an logischen Intervallen | Standalone | ✅ | `strategic-compact` | — |
| `@save-prompts-inject` | Prompts in `~/.cursor/prompts/` speichern/injecten | Standalone | ⚠️ | `save prompt`, `use prompt`, `inject prompt`, `list prompts`, `delete prompt` | `~/.cursor/prompts/` (Cursor-Pfad) |
| `@ponytail` | Lazy-senior-dev-Modus, YAGNI-Ladder, Intensitätslevel | Ponytail | ✅ | `ponytail`, `be lazy`, `yagni`, `do less`, `shortest path` | — |
| `@ponytail-review` | Review nur auf Over-Engineering | Ponytail | ✅ | `review for over-engineering`, `what can we delete`, `/ponytail-review` | — |
| `@ponytail-audit` | Whole-Repo-Audit auf Over-Engineering, ranked report | Ponytail | ✅ | `audit this codebase`, `find bloat`, `/ponytail-audit` | — |
| `@ponytail-debt` | `ponytail:`-Kommentare im Code → Debt-Ledger | Ponytail | ✅ | `ponytail debt`, `what did ponytail defer`, `ponytail ledger` | — |
| `@ponytail-gain` | Ponytail-Impact-Scoreboard (less code, less cost, more speed) | Ponytail | ✅ | `ponytail gain`, `what does ponytail save`, `/ponytail-gain` | — |
| `@ponytail-help` | Quick-Reference-Card für alle Ponytail-Modi | Ponytail | ✅ | `ponytail help`, `how do I use ponytail`, `/ponytail-help` | — |
| `@ecccheck` | **deprecated** → `@ecc-check` | ECC (legacy) | — | — | — |
| `@prepare-deploy-pr` | **deprecated** → `@commit-pr-safe` | ECC (legacy) | — | — | — |

**Legende Wind:** ✅ voll kompatibel (pure Markdown-Logik, keine Cursor-spezifischen Abhängigkeiten) · ⚠️ funktionsfähig, aber mit Einschränkung (Subagent-Abhängigkeit, Cursor-spezifischer Pfad, oder `disable-model-invocation` wird ignoriert) · ❌ nicht kompatibel. Siehe [`docs/WINDSURF-COMPATIBILITY.md`](docs/WINDSURF-COMPATIBILITY.md) für Details.

## Pipeline

Die ECC-Skills bilden eine zusammenhängende Pipeline. `@ecc-runner` orchestriert sie pro Issue autonom; die einzelnen Skills kannst du auch manuell aufrufen.

```
@feature-intake  →  @pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket  →  @ecc-check  →  @commit-pr-safe
                                                                                                                ↑
                                          @ecc-runner orchestriert das ganze pro Issue (batch mode)
```

Siehe [`docs/PIPELINE.md`](docs/PIPELINE.md) für die detaillierte Phasen-Beschreibung und [`docs/ECC-STACK.md`](docs/ECC-STACK.md) für die Erklärung des ECC-Systems.

## Systeme / Basen

| Basis | Skills | Beschreibung |
|-------|--------|--------------|
| **ECC** | `ecc-check`, `ecc-runner`, `feature-intake`, `pingpong-solution`, `implement`, `foundations`, `verify-ticket`, `verify-ui`, `review-ticket`, `commit-pr-safe`, `commit-push-safe`, `pr-merge-safe`, `verification-loop`, `ecccheck` (deprecated), `prepare-deploy-pr` (deprecated) | Eigene Engineering-Disziplin-Suite: deterministische Checks, Acceptance-Verträge, Code-Review-Gate, AgentShield, sicheres Ship. Pro-Projekt-Konfiguration in `.qa/project.yaml`, `.qa/runner-profile.yaml`, `AGENTS.md`. |
| **Ponytail** | `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` | YAGNI/Minimalismus-Werkzeuge: lazy-senior-dev-Modus, Over-Engineering-Review, Repo-Audit, Debt-Tracking, Impact-Scoreboard. |
| **Standalone** | `project-setup`, `mine-stars`, `search-first`, `documentation-lookup`, `security-review`, `strategic-compact`, `save-prompts-inject` | Unabhängige Einzel-Skills ohne Pipeline-Abhängigkeit. |

## Verzeichnisstruktur

```
skills/<name>/SKILL.md           # Pflicht — Skill-Definition mit Frontmatter
skills/<name>/references/         # optional, z.B. implement/references/
skills/<name>/commands.md         # optional, z.B. commit-pr-safe/commands.md
docs/                             # Begleitdokumentation
scripts/                          # install.sh, sync.sh, verify.sh
```

## Update-Workflow

```bash
# Skills lokal bearbeiten (Symlinks zeigen direkt ins Repo)
cd ~/repos/manic-skills
git add -A && git commit -m "update foo skill" && git push

# Neue Maschine / anderer Account:
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --all   # Cursor + Windsurf
```

Weil `install.sh` Symlinks anlegt, editierst du automatisch die Repo-Dateien, wenn du Skills in `~/.cursor/skills/` oder `~/.codeium/windsurf/skills/` änderst. Ein `git status` im Repo zeigt dir dann sofort, was sich geändert hat.

## Was NICHT ins Repo gehört

- `~/.cursor/skills-cursor/` — offizielle Cursor-Skills (synced von Cursor selbst via `.sync-manifest.json`)
- `~/.codex/skills/` — Codex-CLI, anderes Tool
- `~/.agents/skills/` — anderes Agent-Harness
- projektlokale Skills in `<workspace>/.cursor/skills/`, `<workspace>/.windsurf/skills/`, `<workspace>/.agents/skills/`, `<workspace>/.claude/skills/` (reisen mit dem jeweiligen Projekt-Repo)

## Lizenz

Individuell pro Skill (siehe `license:`-Feld im Frontmatter). Ponytail steht unter MIT. Andere Skills ohne Lizenzfeld sind privat/unlizenziert.