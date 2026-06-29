# Windsurf Compatibility

Skills in diesem Repo funktionieren in **Cursor** und **Windsurf** (Cascade), weil beide Tools praktisch dasselbe Skill-Format verwenden. Diese Dokumentation erklärt die Unterschiede, Einschränkungen und Workarounds.

## Format-Kompatibilität

Beide Tools erwarten `SKILL.md` mit YAML-Frontmatter und Markdown-Body. Die Pflicht-Felder sind identisch:

| Feld | Cursor | Windsurf | Status |
|------|--------|----------|--------|
| `name` | Pflicht | Pflicht | ✅ identisch |
| `description` | Pflicht | Pflicht | ✅ identisch — Trigger-Wörter funktionieren in beiden |
| `disable-model-invocation` | optional | **unbekannt** | ⚠️ Windsurf ignoriert es → Auto-Invocation auch für manuell-only Skills |
| `argument-hint` | optional | **unbekannt** | ⚠️ Windsurf ignoriert es |
| `license` | optional | optional (Metadaten) | ✅ ignoriert, stört nicht |

## Pfad-Kompatibilität

| Scope | Cursor | Windsurf |
|-------|--------|----------|
| Global | `~/.cursor/skills/<name>/SKILL.md` | `~/.codeium/windsurf/skills/<name>/SKILL.md` |
| Workspace | `<workspace>/.cursor/skills/<name>/SKILL.md` | `<workspace>/.windsurf/skills/<name>/SKILL.md` |

`install.sh --all` legt Symlinks in **beide** globalen Verzeichnisse, die auf dasselbe Repo zeigen. So reicht ein `git pull`, um beide Tools zu aktualisieren.

## Invocation-Kompatibilität

Beide Tools unterstützen zwei Invocation-Modi:

1. **Auto-Invocation** — das Model lädt den Skill automatisch, wenn die User-Anfrage zur `description` passt (progressive disclosure: nur `name` + `description` werden geladen, bis der Skill invoked wird)
2. **Manuelle Invocation** — User tippt `@skill-name` im Chat

Unterschied: Cursor respektiert `disable-model-invocation: true` (Skill wird nur manuell invoked). Windsurf kennt dieses Feld nicht und auto-invoked alle Skills, deren `description` passt.

## Skill-Kompatibilität im Detail

### ✅ Voll kompatibel (pure Markdown-Logik, keine Cursor-Abhängigkeiten)

Diese Skills referenzieren keine Cursor-spezifischen Subagents, Pfade oder MCP-Server, die Windsurf nicht kennt. Sie funktionieren 1:1.

| Skill | Hinweis |
|-------|---------|
| `@foundations` | Pure SE-Referenz |
| `@feature-intake` | Schreibt `.qa/design/`, `.qa/intake/` — funktioniert in jedem Tool |
| `@pingpong-solution` | Sokratisches Discovery, schreibt `.qa/design/` |
| `@verify-ticket` | Läuft `npm run verify`, validiert gegen `.qa/acceptance/` |
| `@verify-ui` | Bootstrapped Playwright bei Bedarf, nutzt AGENTS.md |
| `@commit-pr-safe` | Git-Workflow, liest AGENTS.md, läuft AgentShield |
| `@commit-push-safe` | Git-Workflow |
| `@verification-loop` | Läuft build/typecheck/lint/test/security |
| `@project-setup` | Repo-Bootstrap (PRD, AGENTS.md, README, `.qa/`) |
| `@mine-stars` | GitHub-Stars durchsuchen (GitHub API) |
| `@documentation-lookup` | Context7 MCP — funktioniert in Windsurf, sofern Context7 dort als MCP konfiguriert ist |
| `@security-review` | Security-Checklist (Auth, Input, Secrets, Payments) |
| `@strategic-compact` | Kontext-Kompaktion |
| `@ponytail` | YAGNI-Ladder, pure Logik |
| `@ponytail-review` | Over-Engineering-Review |
| `@ponytail-audit` | Repo-Audit |
| `@ponytail-debt` | Debt-Ledger |
| `@ponytail-gain` | Impact-Scoreboard |
| `@ponytail-help` | Quick-Reference |

### ⚠️ Funktionsfähig mit Einschränkung

Diese Skills funktionieren in Windsurf, haben aber Cursor-spezifische Abhängigkeiten oder Verhalten, die nicht 1:1 übertragen werden.

| Skill | Einschränkung in Windsurf | Workaround |
|-------|---------------------------|------------|
| `@ecc-check` | `disable-model-invocation: true` wird ignoriert → Windsurf auto-invoked den Skill auch ohne `@ecc-check`-Aufruf. Außerdem ruft `@ecc-check` Phase C `@review-ticket` auf, das wiederum `@review-bugbot`/`@review-security` (Cursor-subagents) braucht. | Manuell aufrufen. Für Code-Review: Windsurf-eigenen Review verwenden oder `@review-ticket` ohne Subagents laufen lassen (Skill erkennt fehlende Subagents und reportet). |
| `@ecc-runner` | Ruft die ganze ECC-Pipeline auf, inkl. `@review-ticket` (Subagent-Abhängigkeit). | `ecc-runner step` verwenden, um einzelne Phasen zu laufen, die keine Subagents brauchen. |
| `@implement` | Ruft `@search-first` auf, das einen "researcher agent" (Cursor-subagent) invoke. | `@search-first` überspringen oder durch Windsurf-eigenen Research-Mechanismus ersetzen. `@documentation-lookup` (Context7 MCP) funktioniert kompatibel. |
| `@review-ticket` | Ruft `@review-bugbot` und `@review-security` auf — offizielle Cursor-Skills unter `~/.cursor/skills-cursor/`, in Windsurf nicht verfügbar. | Skill erkennt fehlende Subagents und reportet. Für vollen Review: Windsurf-eigenen Code-Review verwenden oder Subagent-Aufrufe manuell durch Windsurf-Äquivalente ersetzen. |
| `@pr-merge-safe` | Ruft `@babysit` auf (offizielle Cursor-Skill unter `~/.cursor/skills-cursor/`), in Windsurf nicht verfügbar. | `@babysit`-Aufruf manuell durch Windsurf-eigenes PR-Monitoring ersetzen. |
| `@search-first` | Invoke "researcher agent" — Cursor-spezifischer Subagent. | Stattdessen `@documentation-lookup` (Context7 MCP) für Library-Docs verwenden. Für allgemeine Recherche: Windsurf-eigenen Research-Workflow. |
| `@save-prompts-inject` | Speichert Prompts nach `~/.cursor/prompts/` (Cursor-Pfad hardcoded). | Für Windsurf: Pfad im Skill auf `~/.codeium/windsurf/prompts/` anpassen (oder Symlink anlegen: `ln -sfn ~/.codeium/windsurf/prompts ~/.cursor/prompts`). |

### ❌ Nicht kompatibel

Keine Skills in diesem Repo sind vollständig inkompatibel. Alle sind mindestens funktionsfähig mit Einschränkung.

## Externe Abhängigkeiten in Windsurf

| Abhängigkeit | In Windsurf verfügbar? | Hinweis |
|--------------|-------------------------|---------|
| `npm run verify` | ✅ ja | Tool-unabhängig, läuft im Projekt |
| `npx ecc-agentshield` | ✅ ja | CLI-Tool, tool-unabhängig |
| `gh` (GitHub CLI) | ✅ ja | CLI-Tool, tool-unabhängig |
| Playwright | ✅ ja | `@verify-ui` bootstrapped es bei Bedarf |
| Context7 MCP | ✅ ja | Muss in Windsurf als MCP konfiguriert sein |
| `@review-bugbot` (Cursor-subagent) | ❌ nein | Offizielle Cursor-Skill, nicht in Windsurf |
| `@review-security` (Cursor-subagent) | ❌ nein | Offizielle Cursor-Skill, nicht in Windsurf |
| `@babysit` (Cursor-skill) | ❌ nein | Offizielle Cursor-Skill, nicht in Windsurf |
| "researcher agent" (Cursor-subagent) | ❌ nein | Cursor-spezifisch, von `@search-first` verwendet |

## Konfiguration in Windsurf

### MCP für `@documentation-lookup`

Context7 MCP muss in Windsurf konfiguriert sein. Siehe Windsurf-Doku zu MCP-Servern. Sobald Context7 registriert ist, funktioniert `@documentation-lookup` ohne Anpassung.

### AGENTS.md

Beide Tools (Cursor und Windsurf) lesen `AGENTS.md` im Projekt-Root. Skills, die `AGENTS.md` referenzieren (`@commit-pr-safe`, `@verification-loop`, `@project-setup`, etc.), funktionieren in beiden Tools, sofern `AGENTS.md` im Projekt existiert.

### `.qa/`-Verzeichnis

Skills, die `.qa/project.yaml`, `.qa/runner-profile.yaml`, `.qa/acceptance/`, `.qa/design/` verwenden, sind tool-unabhängig — diese Dateien gehören zum Projekt, nicht zum Tool.

## Empfehlung für parallele Nutzung

1. **`install.sh --all`** verwenden — ein Repo, zwei Tools, ein `git pull` für Updates.
2. **Subagent-abhängige Skills** (`@review-ticket`, `@pr-merge-safe`) in Windsurf manuell aufrufen und fehlende Subagents durch Windsurf-eigenen Review ersetzen.
3. **`disable-model-invocation: true` Skills** (`@ecc-check`, `@ecc-runner`, `@foundations`, `@verify-ticket`, `@verify-ui`, `@review-ticket`, `@feature-intake`, `@pingpong-solution`, `@pr-merge-safe`, `@mine-stars`, `@project-setup`) in Windsurf bewusst manuell aufrufen, auch wenn Windsurf sie auto-invoken würde.
4. **`@save-prompts-inject`** in Windsurf: entweder Pfad im Skill anpassen oder Symlink `~/.cursor/prompts → ~/.codeium/windsurf/prompts` anlegen.

## Referenzen

- [Windsurf Cascade Skills Doku](https://docs.windsurf.com/windsurf/cascade/skills)
- [Windsurf Rules Doku](https://docs.windsurf.com/windsurf/cascade/memories)
- [Windsurf .windsurf/rules/*.md Reference](https://agentconfig.ing/files/windsurf-rules-md/)