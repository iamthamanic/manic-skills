# Manic Skills

Persönliche Agent-Skills für **Cursor**, **Windsurf**, **pi.dev** und **Claude Code** — maschinenlokal gespiegelt via Git. Portabel, account-unabhängig. Klone das Repo, führe `scripts/install.sh` aus, und alle Skills sind auf der neuen Maschine aktiv.

## Was sind Skills?

Skills folgen dem **Agent Skills Standard** (offen seit Dezember 2025 von Anthropic). Das Format ist für alle vier Tools identisch: `SKILL.md` mit YAML-Frontmatter (`name`, `description`) und Markdown-Body. Sie werden vom Model automatisch geladen, wenn die User-Anfrage zur `description` passt (progressive disclosure), oder manuell via `@skill-name` (Cursor/Windsurf) bzw. `/skill:name` (pi.dev/Claude Code) aufgerufen.

| Tool | Global (maschinenlokal) | Workspace (projektlokal) | Invocation |
|------|-------------------------|--------------------------|------------|
| Cursor | `~/.cursor/skills/<name>/` | `<workspace>/.cursor/skills/` | `@skill-name` |
| Windsurf | `~/.codeium/windsurf/skills/<name>/` | `<workspace>/.windsurf/skills/` | `@skill-name` |
| pi.dev | `~/.pi/agent/skills/<name>/` oder `~/.agents/skills/` | `<workspace>/.pi/skills/` oder `<workspace>/.agents/skills/` | `/skill:name` |
| Claude Code | `~/.claude/skills/<name>/` | `<workspace>/.claude/skills/` | `/skill-name` |

Frontmatter-Felder, die nur einzelne Tools kennen (`disable-model-invocation`, `argument-hint`, `context: fork`, `compatibility`), werden von den anderen Tools ignoriert — sie stören nicht. Details in [`docs/TOOL-COMPATIBILITY.md`](docs/TOOL-COMPATIBILITY.md).

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

**pi.dev:**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --pi
```

**Claude Code:**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --claude
```

**Alle vier Tools parallel:**

```bash
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --all
```

`install.sh` legt Symlinks von `<tool-skills-dir>/<name>` → `~/repos/manic-skills/skills/<name>`.
Danach reicht `git pull`, um alle Skills in allen Tools zu aktualisieren — ein Repo, vier Tools, ein Update.

Siehe [`INSTALL.md`](INSTALL.md) für alternative Installationsmethoden (copy, direkter Klon, Updates, Deinstallation) und [`docs/TOOL-COMPATIBILITY.md`](docs/TOOL-COMPATIBILITY.md) für detaillierte Kompatibilitäts-Hinweise.

## Skill-Index

Vollständige Tabelle aller Skills. **Basis**: ECC (Quality-Gate-Suite), Ponytail (YAGNI), Standalone. **C** = Cursor, **W** = Windsurf, **P** = pi.dev, **CC** = Claude Code. ✅ voll · ⚠️ mit Einschränkung.

| Skill | Zweck | How to use | C | W | P | CC |
|-------|-------|------------|---|---|---|----|
| `@test-gate` | Deterministische Tools/Scripts (Exit-Code-Gate) | **Situation:** Lint/tsc/prettier/prisma/RG ohne LLM-Urteil. **Was passiert:** Stack aus `project.yaml`/`detect-stack.sh`, führt Checks aus, Report PASS/FAIL. **Beispiel:** `@test-gate depth=standard` → tsc+lint+typed-strict → `PASS`. Phase A von `@ecc-check`. | ✅ | ✅ | ✅ | ✅ |
| `@ecc-check` | Quality-Gate-Loop bis READY/BLOCKED | **Situation:** Feature fertig, willst wissen ob ready zum Committen. **Was passiert:** Phase A = `@test-gate`, dann Acceptance, `@review-ticket`, AgentShield, UI, Report. **Beispiel:** `@ecc-check` → `@test-gate` PASS → `@review-ticket` ACCEPT → `READY`. | ✅ | ⚠️ | ✅ | ✅ |
| `@audit-changes` | Fast-Lane-Audit (Security, SOLID, KISS, DRY) | **Situation:** Schnell codiert ohne volle Pipeline, willst Sicherheits-/Qualitäts-Sanity. **Was passiert:** Scope, Phase A = `@test-gate` (depth), Security-Scan, Review lite. **Beispiel:** `@audit-changes depth: quick` → `@test-gate` quick → `CLEAN` → vor PR `@ecc-check`. | ✅ | ✅ | ✅ | ✅ |
| `@ecc-runner` | Autonomer GitHub-Issue-Queue-Runner | **Situation:** 5 offene Issues, automatisch abarbeiten. **Was passiert:** Bootstrapped Labels, baut Queue, arbeitet jedes Issue mit voller Pipeline (implement→verify→review→PR). **Beispiel:** `@ecc-runner` → Issue #42: implement→verify→review→PR #78 → Issue #43 → ... bis Queue leer. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@feature-intake` | Epic → Design → Issues, nur nach User-OK | **Situation:** Grobe Feature-Idee, in Issues zerlegen. **Was passiert:** Analysiert PRD gegen Repo, stellt Fragen, schreibt `.qa/design/`, zerlegt in Issue-Drafts. **Beispiel:** `@feature-intake` mit PRD → 3 Slices → User bestätigt → Issues erstellt → `@ecc-runner`. | ✅ | ✅ | ✅ | ✅ |
| `@pingpong-solution` | Pre-Implementation Solution-Ping-Pong | **Situation:** Unsicher wie Feature sich integriert. **Was passiert:** Sokratische Discovery, Optionen mit Evidenz, Codebase-Fit, schreibt `.qa/design/`. **Beispiel:** "Wie baue ich Audio-Export?" → Skill bietet 2 Optionen → User wählt A → `.qa/design/audio-export.md` → `@implement`. | ✅ | ✅ | ✅ | ✅ |
| `@implement` | Implementation Contract, Acceptance-Auto-Gen | **Situation:** Design steht, Code schreiben. **Was passiert:** Auto-generiert `.qa/acceptance/` vor Code, minimale Diffs, Ponytail-Ladder, Helper inline. **Beispiel:** `@implement` → `.qa/acceptance/audio-export.md` → sucht Patterns → implementiert minimalen Diff → `@verify-ticket`. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@foundations` | SE-Referenz (Parnas, Liskov, Hoare, Dijkstra, Brooks) | **Situation:** Designst Modul, unsicher über Boundary. **Was passiert:** Reference Skill mit Finding-Tags (`parnas:`, `liskov:`, `hoare:`). **Beispiel:** `@foundations` → § Parnas → "Audio-Modul leakt State" → Tag `parnas:` in Review. | ✅ | ✅ | ✅ | ✅ |
| `@verify-ticket` | Technische Verifikation gegen Acceptance | **Situation:** Implementation fertig, gegen Kriterien validieren. **Was passiert:** `@test-gate` depth=standard + Diff vs `.qa/acceptance/`. **Beispiel:** `@verify-ticket` → test-gate PASS → Acceptance matched → PASS. | ✅ | ✅ | ✅ | ✅ |
| `@typed-strict` | Keine Type-Escape-Hatches (Boy Scout) | **Situation:** Touched Files noch mit `any`/`type: ignore`. **Was passiert:** Language-Matrix + `rg` auf Diff; Teil von `@test-gate`. **Beispiel:** `@typed-strict` → 2× `as any` → FAIL bis entfernt. | ✅ | ✅ | ✅ | ✅ |
| `@verify-ui` | UI/UX-Verifikation (Playwright, Screenshots) | **Situation:** UI-Änderungen, visuell verifizieren. **Was passiert:** Bootstrapped Playwright, läuft e2e-Szenarien mit Screenshots. **Beispiel:** `@verify-ui` → "App lädt" Screenshot → "Dialog öffnet" Screenshot → Edge Cases → Report grün. | ✅ | ✅ | ✅ | ✅ |
| `@review-ticket` | Code-Quality-Review, ACCEPT/CHANGES_REQUESTED | **Situation:** Code fertig, Review vor PR. **Was passiert:** Architektur, Security, Diff-Scope. Ruft Subagents bei Bedarf. **Beispiel:** `@review-ticket` → "Diff 50 Zeilen, Acceptance 200" → `CHANGES_REQUESTED` → fix → `ACCEPT`. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@commit-pr-safe` | Commit + Push + PR auf non-main | **Situation:** Quality Gate READY, commit+push+PR. **Was passiert:** Liest AGENTS.md, validiert non-main, Secret-Scan, AgentShield, README-Sync, PR. **Beispiel:** `@commit-pr-safe` → branch `feature/audio-export` → kein Secret → commit → push → PR #78. | ✅ | ✅ | ✅ | ✅ |
| `@commit-push-safe` | Commit + Push ohne PR | **Situation:** WIP-Commit ohne PR. **Was passiert:** Wie commit-pr-safe, ohne PR. **Beispiel:** `@commit-push-safe` → `wip: scaffold` → push → fertig (kein PR). | ✅ | ✅ | ✅ | ✅ |
| `@pr-merge-safe` | PR reviewen + mergen wenn green | **Situation:** PR offen, CI läuft, reviewen+mergen. **Was passiert:** verify-ticket, review-ticket, ecc-check, babysit. Merged bei User-OK. **Beispiel:** `@pr-merge-safe` → CI green → review ACCEPT → "Merge? y" → merged. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@verification-loop` ⚠️ | Legacy Pre-PR Gate → prefer `@test-gate` / `@ecc-check` | **Situation:** Alte Checklisten-Phasen. **Was passiert:** Verweist auf `@test-gate`. **Beispiel:** lieber `@test-gate depth=standard`. | ✅ | ✅ | ✅ | ✅ |
| `@ecc-runner-loop` | Issue-Queue + Merge-Loop | **Situation:** Issues bis merged durchziehen. **Was passiert:** Composed Runner mit ecc-check/PR-merge. **Beispiel:** `@ecc-runner-loop` → implement→test-gate→review→PR→merge. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@memory-live-doc` | Living bilingual Project Memory | **Situation:** Materialer Diff, Docs aktuell halten. **Was passiert:** Aktualisiert `.project-memory/` aus Git-Diff. **Beispiel:** `@memory-live-doc` mode=apply nach Feature. | ✅ | ✅ | ✅ | ✅ |
| `@debug` | Reproduce-first Debugging | **Situation:** Bug/Console-Error. **Was passiert:** Evidenz vor Fix (Iron Law). **Beispiel:** `@debug` → repro → root cause → fix. | ✅ | ✅ | ✅ | ✅ |
| `@frontend-design` / `@design-taste-frontend` | Intentional UI / Anti-slop Design | **Situation:** Neue UI oder Redesign. **Was passiert:** Design-Constraints, keine Generic-AI-Looks. **Beispiel:** `@frontend-design` vor Component-Build. | ✅ | ✅ | ✅ | ✅ |
| `@web-design-guidelines` | Static a11y/UX Checklist | **Situation:** UI geändert, vor Browser-Proof. **Was passiert:** Web Interface Guidelines Audit. **Beispiel:** vor `@verify-ui`. | ✅ | ✅ | ✅ | ✅ |
| `@find-skills` | Skills.sh Discovery | **Situation:** Gibt es schon einen Skill dafür? **Was passiert:** `npx skills find` + Qualitätsfilter. **Beispiel:** `@find-skills` "quality gate". | ✅ | ✅ | ✅ | ✅ |
| `@api-design` / `@system-design-reference` / `@handoff` / `@zoom-out` | API/System-Design / Handoff / Area-Map | Helper-Skills für Contracts, Infra-Patterns, Session-Übergabe, Modul-Orientierung. | ✅ | ✅ | ✅ | ✅ |
| `@project-setup` | Repo-Bootstrap | **Situation:** Neues Projekt, PRD/AGENTS/README anlegen. **Was passiert:** Generiert alle Dateien, entdeckt Stack. **Beispiel:** `@project-setup` → Next.js erkannt → PRD.md, AGENTS.md, README.md, .qa/. | ✅ | ✅ | ✅ | ✅ |
| `@mine-stars` | GitHub-Stars durchsuchen | **Situation:** Ähnliche Patterns in Stars finden. **Was passiert:** Durchsucht Stars nach Patterns/Ideen, cross-domain. **Beispiel:** `@mine-stars` "audio waveform" → 3 starred Repos → d3-wave Pattern anwendbar. | ✅ | ✅ | ✅ | ✅ |
| `@search-first` | Research-before-coding | **Situation:** Utility schreiben, erst prüfen ob existiert. **Was passiert:** Sucht existierende Tools/Libs/Patterns. **Beispiel:** `@search-first` "rate limiter" → `express-rate-limit` bereits installiert → keine custom Implementation. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@documentation-lookup` | Library-Docs via Context7 MCP | **Situation:** Aktuelle React-Docs statt Training-Data. **Was passiert:** Lädt up-to-date Docs via Context7. **Beispiel:** `@documentation-lookup` "Next.js 14 App Router" → aktuelle Docs → Server Components können async. | ✅ | ✅ | ✅ | ✅ |
| `@security-review` | Security-Checklist | **Situation:** Auth-Endpoint, Security prüfen. **Was passiert:** Checklist für Auth, Input, Secrets, Payments. **Beispiel:** `@security-review` "login" → Input validation ✓, Password hashing ✓, Rate limiting ✗ → hinzufügen. | ✅ | ✅ | ✅ | ✅ |
| `@strategic-compact` | Kontext-Kompaktion | **Situation:** Lange Session, Context groß. **Was passiert:** Kompakt an logischen Intervallen (nach acceptance, vor bulk coding). **Beispiel:** `@strategic-compact` nach Phase 2 → kompaktieren → schlank für Phase 3. | ✅ | ✅ | ✅ | ✅ |
| `@save-prompts-inject` | Prompts speichern/injecten | **Situation:** Prompt wiederverwenden. **Was passiert:** Speichert in `~/.cursor/prompts/`, inject in jede Session. **Beispiel:** `save prompt review-checklist` → nächste Session: `use prompt review-checklist` → injected. | ✅ | ⚠️ | ⚠️ | ⚠️ |
| `@ponytail` | Lazy-senior-dev-Modus, YAGNI-Ladder | **Situation:** Neigst zu Over-Engineering. **Was passiert:** Persistent: YAGNI-Ladder — braucht es das? stdlib? native? one-liner? **Beispiel:** `@ponytail` "Baue Cache" → "Meinst du `@lru_cache`?" → one-liner statt Custom-Klasse. | ✅ | ✅ | ✅ | ✅ |
| `@ponytail-review` | Review nur auf Over-Engineering | **Situation:** Review fertig, zusätzlich auf Over-Engineering prüfen. **Was passiert:** Findet reinvented stdlib, unneeded deps, speculative abstractions. **Beispiel:** `@ponytail-review` → "Custom Cache 80 Zeilen → lru_cache 1 Zeile" → cutten. | ✅ | ✅ | ✅ | ✅ |
| `@ponytail-audit` | Whole-Repo-Audit auf Over-Engineering | **Situation:** Codebase erben, was überflüssig? **Was passiert:** Scannt ganzes Repo, ranked Liste. **Beispiel:** `@ponytail-audit` → "1. Custom Cache → lru_cache (-79 Zeilen) / 2. Custom Modal → Radix (-120 Zeilen)". | ✅ | ✅ | ✅ | ✅ |
| `@ponytail-debt` | `ponytail:`-Kommentare → Debt-Ledger | **Situation:** Ponytail hat Shortcuts hinterlassen, tracken. **Was passiert:** Erntet alle `ponytail:`-Kommentare. **Beispiel:** `@ponytail-debt` → 3 shortcuts: global lock, naive heuristic, ... → Ledger. | ✅ | ✅ | ✅ | ✅ |
| `@ponytail-gain` | Ponytail-Impact-Scoreboard | **Situation:** Sehen was Ponytail spart. **Was passiert:** Scoreboard: less code, less cost, more speed. **Beispiel:** `@ponytail-gain` → "Code: -2,400 Zeilen / Deps: -4 / Build: -18s". | ✅ | ✅ | ✅ | ✅ |
| `@ponytail-help` | Quick-Reference für Ponytail-Modi | **Situation:** Alle Ponytail-Kommandos sehen. **Was passiert:** One-shot Card aller Modi/Skills/Commands. **Beispiel:** `@ponytail-help` → Card: lite/full/ultra, review, audit, debt, gain. | ✅ | ✅ | ✅ | ✅ |
| `@ecccheck` ⚠️ | **deprecated** → `@ecc-check` | Nicht verwenden. | — | — | — | — |
| `@prepare-deploy-pr` ⚠️ | **deprecated** → `@commit-pr-safe` | Nicht verwenden. | — | — | — | — |

**Legende:** ✅ voll kompatibel · ⚠️ funktionsfähig mit Einschränkung (Subagent-Abhängigkeit, Cursor-Pfad, oder `disable-model-invocation` ignoriert) — siehe [`docs/TOOL-COMPATIBILITY.md`](docs/TOOL-COMPATIBILITY.md).

## Pipeline

Die ECC-Skills bilden eine zusammenhängende Pipeline. `@ecc-runner` orchestriert sie pro Issue autonom; die einzelnen Skills kannst du auch manuell aufrufen.

```
@feature-intake  →  @pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket  →  @ecc-check  →  @commit-pr-safe
                                                                                                                ↑
                                          @ecc-runner orchestriert das ganze pro Issue (batch mode)
```

**Fast Lane** (wenn du die Pipeline überspringst): `@audit-changes` während der Arbeit → `@ecc-check` vor PR/Ship.

Siehe [`docs/PIPELINE.md`](docs/PIPELINE.md) für die detaillierte Phasen-Beschreibung und [`docs/ECC-STACK.md`](docs/ECC-STACK.md) für die Erklärung des ECC-Systems.

## Systeme / Basen

| Basis | Skills | Beschreibung |
|-------|--------|--------------|
| **ECC** | `audit-changes`, `ecc-check`, `ecc-runner`, `feature-intake`, `pingpong-solution`, `implement`, `foundations`, `verify-ticket`, `verify-ui`, `review-ticket`, `commit-pr-safe`, `commit-push-safe`, `pr-merge-safe`, `verification-loop`, `ecccheck` (deprecated), `prepare-deploy-pr` (deprecated) | Engineering-Disziplin-Suite: Fast-Lane-Audit, deterministische Checks, Acceptance-Verträge, Code-Review-Gate, AgentShield, sicheres Ship. Pro-Projekt-Konfiguration in `.qa/project.yaml`, `.qa/runner-profile.yaml`, `AGENTS.md`. |
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
bash ~/repos/manic-skills/scripts/install.sh --all   # alle vier Tools
```

Weil `install.sh` Symlinks anlegt, editierst du automatisch die Repo-Dateien, wenn du Skills in einem Tool-Verzeichnis änderst. Ein `git status` im Repo zeigt dir dann sofort, was sich geändert hat.

## Was NICHT ins Repo gehört

- `~/.cursor/skills-cursor/` — offizielle Cursor-Skills (synced von Cursor selbst)
- `~/.codex/skills/` — Codex-CLI, anderes Tool
- `~/.agents/skills/` — anderes Agent-Harness (pi.dev lädt diese aber auch)
- projektlokale Skills in `<workspace>/.cursor/skills/`, `<workspace>/.windsurf/skills/`, `<workspace>/.pi/skills/`, `<workspace>/.claude/skills/`, `<workspace>/.agents/skills/` (reisen mit dem jeweiligen Projekt-Repo)

## Lizenz

Individuell pro Skill (siehe `license:`-Feld im Frontmatter). Ponytail steht unter MIT. Andere Skills ohne Lizenzfeld sind privat/unlizenziert.