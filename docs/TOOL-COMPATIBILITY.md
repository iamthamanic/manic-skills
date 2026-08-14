# Tool Compatibility

Skills in diesem Repo folgen dem **Agent Skills Standard** (offen seit Dezember 2025 von Anthropic). Das `SKILL.md`-Format ist identisch für alle vier Tools — sie unterscheiden sich nur in den Pfaden und ein paar Frontmatter-Feldern.

## Unterstützte Tools

| Tool | Skill-Pfad (global) | Skill-Pfad (workspace) | Frontmatter-Unterschiede |
|------|---------------------|------------------------|--------------------------|
| **Cursor** | `~/.cursor/skills/<name>/SKILL.md` | `<workspace>/.cursor/skills/<name>/SKILL.md` | kennt `disable-model-invocation`, `argument-hint` |
| **Windsurf** | `~/.codeium/windsurf/skills/<name>/SKILL.md` | `<workspace>/.windsurf/skills/<name>/SKILL.md` | ignoriert `disable-model-invocation` → auto-invoked |
| **pi.dev** | `~/.pi/agent/skills/<name>/SKILL.md` oder `~/.agents/skills/<name>/SKILL.md` | `<workspace>/.pi/skills/<name>/SKILL.md` oder `<workspace>/.agents/skills/<name>/SKILL.md` | kennt `disable-model-invocation` ✓, `compatibility`, `metadata`, `allowed-tools` |
| **Claude Code** | `~/.claude/skills/<name>/SKILL.md` | `<workspace>/.claude/skills/<name>/SKILL.md` | kennt `disable-model-invocation` ✓, `user-invocable`, `allowed-tools`, `context: fork`, `agent` |

## Format-Kompatibilität

Alle vier Tools erwarten `SKILL.md` mit YAML-Frontmatter und Markdown-Body. Pflicht-Felder:

| Feld | Cursor | Windsurf | pi.dev | Claude Code | Status |
|------|--------|----------|--------|------------|--------|
| `name` | Pflicht | Pflicht | Pflicht | Pflicht | ✅ identisch |
| `description` | Pflicht | Pflicht | Pflicht | Pflicht | ✅ identisch — Trigger in allen Tools |
| `disable-model-invocation` | optional, respektiert | optional, **ignoriert** | optional, respektiert | optional, respektiert | ⚠️ Windsurf auto-invoked |
| `argument-hint` | optional | **unbekannt** | **unbekannt** | optional | ⚠️ nur Cursor nutzt es |
| `license` | optional | optional (Metadaten) | optional | optional | ✅ ignoriert, stört nicht |
| `compatibility` | **unbekannt** | **unbekannt** | optional (max 500 chars) | **unbekannt** | pi.dev-spezifisch |
| `metadata` | **unbekannt** | **unbekannt** | optional (key-value) | **unbekannt** | pi.dev-spezifisch |
| `allowed-tools` | **unbekannt** | **unbekannt** | optional (experimental) | optional | pi.dev + Claude Code |
| `user-invocable` | **unbekannt** | **unbekannt** | **unbekannt** | optional (`false` = hidden) | Claude Code-spezifisch |
| `context` | **unbekannt** | **unbekannt** | **unbekannt** | optional (`fork` = subagent) | Claude Code-spezifisch |
| `agent` | **unbekannt** | **unbekannt** | **unbekannt** | optional (subagent type) | Claude Code-spezifisch |

**Wichtig:** Unbekannte Frontmatter-Felder werden von allen Tools ignoriert — sie stören nicht, sondern werden einfach übersprungen. Du kannst also Felder für Claude Code (`context: fork`) setzen, ohne Cursor/Windsurf/pi.dev zu beeinflussen.

## Invocation-Kompatibilität

Alle vier Tools unterstützen:

1. **Auto-Invocation** — das Model lädt den Skill automatisch, wenn die User-Anfrage zur `description` passt (progressive disclosure)
2. **Manuelle Invocation** — User tippt `@skill-name` (Cursor, Windsurf) bzw. `/skill:name` (pi.dev, Claude Code)

| Tool | Auto-Invocation | Manuelle Invocation | `disable-model-invocation: true` respektiert? |
|------|-----------------|--------------------|------------------------------------------------|
| Cursor | ✅ | `@skill-name` | ✅ ja |
| Windsurf | ✅ | `@skill-name` | ❌ nein (ignoriert, auto-invoked trotzdem) |
| pi.dev | ✅ | `/skill:name` | ✅ ja |
| Claude Code | ✅ | `/skill-name` | ✅ ja |

## Skill-Kompatibilität im Detail

### ✅ Voll kompatibel (alle 4 Tools)

Pure Markdown-Logik, keine Tool-spezifischen Subagents/Pfade. Funktionieren 1:1 in Cursor, Windsurf, pi.dev, Claude Code.

| Skill | Hinweis |
|-------|---------|
| `@foundations` | Pure SE-Referenz |
| `@feature-intake` | Schreibt `.qa/design/`, `.qa/intake/` |
| `@pingpong-solution` | Sokratisches Discovery, schreibt `.qa/design/` |
| `@verify-ticket` | `@test-gate` + Diff vs `.qa/acceptance/` |
| `@composition-gate` | Hop-Ketten-Simulationen; Proof `.qa/runs/composition-gate-<slug>.md`; FLAGGED muss gefixt werden |
| `@verify-ui` | Bootstrapped Playwright bei Bedarf |
| `@commit-pr-safe` | Git-Workflow, liest AGENTS.md, läuft AgentShield |
| `@commit-push-safe` | Git-Workflow |
| `@verification-loop` | Läuft build/typecheck/lint/test/security |
| `@project-setup` | Repo-Bootstrap (PRD, AGENTS.md, README, `.qa/`) |
| `@mine-stars` | GitHub-Stars durchsuchen (GitHub API) |
| `@documentation-lookup` | Context7 MCP — funktioniert in allen Tools, sofern Context7 dort als MCP konfiguriert ist |
| `@security-review` | Security-Checklist |
| `@strategic-compact` | Kontext-Kompaktion |
| `@ponytail` | YAGNI-Ladder, pure Logik |
| `@ponytail-review` | Over-Engineering-Review |
| `@ponytail-audit` | Repo-Audit |
| `@ponytail-debt` | Debt-Ledger |
| `@ponytail-gain` | Impact-Scoreboard |
| `@ponytail-help` | Quick-Reference |

### ⚠️ Funktionsfähig mit Einschränkung

| Skill | Einschränkung | Workaround |
|-------|---------------|------------|
| `@ecc-check` | Windsurf: `disable-model-invocation` ignoriert → auto-invoked. Phase C ruft `@review-ticket` (Subagent-Abhängigkeit). | Manuell aufrufen. Subagent-Abhängigkeit siehe `@review-ticket`. |
| `@ecc-runner` | Ruft ganze ECC-Pipeline inkl. `@review-ticket` (Subagent-Abhängigkeit). | `ecc-runner step` für einzelne Phasen ohne Subagents. |
| `@implement` | Ruft `@search-first` auf (Cursor-researcher-subagent). | `@search-first` überspringen oder `@documentation-lookup` (Context7) verwenden. |
| `@review-ticket` | Ruft `@review-bugbot` / `@review-security` (offizielle Cursor-Skills, nicht in Windsurf/pi.dev/Claude Code). | Skill erkennt fehlende Subagents und reportet. Für vollen Review: Tool-eigenen Code-Review verwenden. |
| `@pr-merge-safe` | Ruft `@babysit` (offizielle Cursor-Skill). | `@babysit`-Aufruf durch Tool-eigenes PR-Monitoring ersetzen. |
| `@search-first` | Invoke "researcher agent" (Cursor-subagent). | `@documentation-lookup` (Context7 MCP) für Library-Docs. Für allgemeine Recherche: Tool-eigenen Research-Workflow. |
| `@save-prompts-inject` | Speichert nach `~/.cursor/prompts/` (Cursor-Pfad hardcoded). | Pfad im Skill anpassen oder Symlink: `ln -sfn ~/.codeium/windsurf/prompts ~/.cursor/prompts`. Für pi.dev: `~/.pi/agent/prompts/`. Für Claude Code: `~/.claude/prompts/`. |

### ❌ Nicht kompatibel

Keine Skills in diesem Repo sind vollständig inkompatibel. Alle sind mindestens funktionsfähig mit Einschränkung.

## Externe Abhängigkeiten pro Tool

| Abhängigkeit | Cursor | Windsurf | pi.dev | Claude Code | Hinweis |
|--------------|--------|----------|--------|-------------|---------|
| `npm run verify` | ✅ | ✅ | ✅ | ✅ | Tool-unabhängig |
| `npx ecc-agentshield` | ✅ | ✅ | ✅ | ✅ | CLI-Tool |
| `gh` (GitHub CLI) | ✅ | ✅ | ✅ | ✅ | CLI-Tool |
| Playwright | ✅ | ✅ | ✅ | ✅ | `@verify-ui` bootstrapped es |
| Context7 MCP | ✅ | ✅ | ✅ | ✅ | Muss als MCP konfiguriert sein |
| `@review-bugbot` (subagent) | ✅ | ❌ | ❌ | ❌ | Offizielle Cursor-Skill |
| `@review-security` (subagent) | ✅ | ❌ | ❌ | ❌ | Offizielle Cursor-Skill |
| `@babysit` (skill) | ✅ | ❌ | ❌ | ❌ | Offizielle Cursor-Skill |
| "researcher agent" (subagent) | ✅ | ❌ | ❌ | ❌ | Cursor-spezifisch |

## pi.dev-spezifische Konfiguration

pi.dev kann Skills aus **anderen Tools** laden, indem du deren Verzeichnisse in den Settings hinzufügst:

```json
// ~/.pi/settings.json
{
  "skills": [
    "~/.claude/skills",
    "~/.codex/skills",
    "~/.cursor/skills"
  ]
}
```

Für dieses Repo empfiehlt sich: entweder `install.sh --pi` (Symlink nach `~/.pi/agent/skills/`) oder pi.dev-Settings auf `~/repos/manic-skills/skills` zeigen lassen.

pi.dev lädt Skills auch aus `~/.agents/skills/` und `<workspace>/.agents/skills/` — falls du bereits dort Skills hast, werden sie automatisch erkannt.

## Claude Code-spezifische Features

Claude Code unterstützt zusätzliche Frontmatter-Felder, die andere Tools ignorieren:

- `user-invocable: false` — Skill wird im Menu versteckt (Background-Knowledge)
- `allowed-tools: Read Write Bash` — beschränkt Tools während Skill aktiv
- `context: fork` — Skill läuft in isoliertem Subagent
- `agent: Explore` — welcher Subagent-Typ (built-in: `Explore`, `Plan`, `general-purpose`)

Diese Felder kannst du setzen, ohne andere Tools zu beeinflussen. Für Skills, die in Claude Code isoliert laufen sollen (z. B. `@ecc-runner`), wäre `context: fork` sinnvoll — aber nur, wenn Claude Code verwendet wird. Für andere Tools ist es harmlos (wird ignoriert).

## Empfehlung für parallele Nutzung (alle 4 Tools)

1. **`install.sh --all`** verwenden — ein Repo, vier Tools, ein `git pull` für Updates
2. **Subagent-abhängige Skills** (`@review-ticket`, `@pr-merge-safe`) in Nicht-Cursor-Tools manuell aufrufen; fehlende Subagents durch Tool-eigenen Review ersetzen
3. **`disable-model-invocation: true` Skills** in Windsurf bewusst manuell aufrufen (Windsurf ignoriert das Feld)
4. **`@save-prompts-inject`** Pfad an Tool anpassen oder Symlinks anlegen
5. **pi.dev-Settings** auf `~/repos/manic-skills/skills` zeigen lassen, um Skills aus diesem Repo direkt zu laden (ohne Symlinks)

## Referenzen

- [Agent Skills Specification](https://agentskills.io/specification)
- [Claude Code Skills Doku](https://code.claude.com/docs/en/skills)
- [Claude Code SKILL.md Frontmatter Reference](https://claudskills.com/learn/claude-code-skill-frontmatter-fields/)
- [Windsurf Cascade Skills Doku](https://docs.windsurf.com/windsurf/cascade/skills)
- [pi.dev Skills Doku](https://pi.dev/docs/latest/skills)
- [Claude Code Skills Complete Guide (2026)](https://duet.so/guides/claude-code-skills-complete-guide)