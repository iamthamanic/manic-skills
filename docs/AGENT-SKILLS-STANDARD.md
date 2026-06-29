# Agent Skills Standard

Alle Skills in diesem Repo folgen dem **Agent Skills Standard** — einer offenen Spezifikation, die Anthropic im Dezember 2025 veröffentlicht hat. Das `SKILL.md`-Format ist seither der gemeinsame Nenner für Cursor, Windsurf, pi.dev, Claude Code, OpenAI Codex CLI und Gemini CLI.

## Was der Standard definiert

Eine Skill ist ein Verzeichnis, das mindestens eine `SKILL.md`-Datei enthält:

```
my-skill/
├── SKILL.md              # Pflicht: Frontmatter + Anweisungen
├── scripts/              # optional: Helper-Skripte
├── references/           # optional: Detail-Docs, on-demand geladen
└── assets/               # optional: Templates, Bilder, etc.
```

### Frontmatter (Pflicht-Felder)

| Feld | Pflicht | Constraints | Beschreibung |
|------|---------|------------|--------------|
| `name` | Ja | Max 64 Zeichen, lowercase a-z, 0-9, hyphens. Nicht starten/endend mit hyphen, keine konsekutiven hyphens. | Eindeutiger Identifier, wird zum Kommando-Namen. |
| `description` | Ja | Max 1024 Zeichen, non-empty. | Was der Skill tut und wann er verwendet wird. Bestimmt Auto-Invocation. |

### Frontmatter (optional)

| Feld | Beschreibung | Tool-Support |
|------|--------------|--------------|
| `license` | Lizenzname oder Referenz auf bundled Datei | alle (Metadaten) |
| `compatibility` | Max 500 Zeichen. Environment-Requirements. | pi.dev |
| `metadata` | Arbitrary key-value mapping. | pi.dev |
| `allowed-tools` | Space-delimited list of pre-approved tools (experimental). | pi.dev, Claude Code |
| `disable-model-invocation` | `true` = Skill hidden from system prompt, nur manuelle Invocation. | Cursor, pi.dev, Claude Code (respektiert); Windsurf (ignoriert) |
| `argument-hint` | Hint für Argumente beim manuellen Aufruf. | Cursor |
| `user-invocable` | `false` = hidden from menus (background knowledge). | Claude Code |
| `context` | `fork` = läuft in isoliertem Subagent. | Claude Code |
| `agent` | Subagent-Typ (`Explore`, `Plan`, `general-purpose` oder custom). | Claude Code |

### Progressive Disclosure

Alle Tools nutzen progressive disclosure in drei Schichten:

1. **Metadata** (~100 tokens): `name` + `description` werden immer geladen (Startup)
2. **Instructions** (< 5000 tokens empfohlen): `SKILL.md` body wird geladen, wenn Skill invoked wird
3. **Resources** (bei Bedarf): `scripts/`, `references/`, `assets/` werden geladen, wenn der Skill sie referenziert

### Body

Der Markdown-Body nach dem Frontmatter enthält die Skill-Anweisungen. Keine Format-Restriktionen — schreibe, was dem Agent hilft. Empfehlung: unter 500 Zeilen, sonst in `references/` auslagern und verlinken.

## Wie die Tools den Standard implementieren

| Tool | Standard-konform | Pfad (global) | Pfad (workspace) | Invocation |
|------|------------------|---------------|-------------------|-----------|
| Cursor | ✅ | `~/.cursor/skills/` | `<workspace>/.cursor/skills/` | `@skill-name` |
| Windsurf | ✅ | `~/.codeium/windsurf/skills/` | `<workspace>/.windsurf/skills/` | `@skill-name` |
| pi.dev | ✅ (lenient) | `~/.pi/agent/skills/`, `~/.agents/skills/` | `<workspace>/.pi/skills/`, `<workspace>/.agents/skills/` | `/skill:name` |
| Claude Code | ✅ | `~/.claude/skills/` | `<workspace>/.claude/skills/` | `/skill-name` |

### pi.dev-Besonderheiten

- Erlaubt Skill-Name ≠ Parent-Directory-Name (Standard verbietet das, pi.dev ist hier lenient)
- Kann Skills aus anderen Tools laden via `settings.json` → `skills`-Array
- Validiert gegen den Standard, warnt bei meisten Violations, lädt Skills aber trotzdem

### Claude Code-Besonderheiten

- Unterstützt `context: fork` (Skill läuft in isoliertem Subagent)
- Unterstützt `agent`-Feld (Subagent-Typ)
- Unterstützt `user-invocable: false` (hidden, background knowledge)
- Plugins können Skills shippen (`skills/` directory im Plugin-Root)

### Windsurf-Besonderheiten

- Ignoriert `disable-model-invocation` (auto-invoked trotzdem)
- Hat zusätzlich `.windsurf/rules/` (trigger-based rules) und Workflows (slash commands) — separate Konzepte neben Skills

### Cursor-Besonderheiten

- Hat offizielle Cursor-Skills unter `~/.cursor/skills-cursor/` (synced via `.sync-manifest.json`)
- Subagents (`@review-bugbot`, `@review-security`, `@babysit`) sind offizielle Cursor-Skills, nicht im Standard

## Warum das für dieses Repo wichtig ist

Weil alle vier Tools denselben Standard implementieren, können wir **ein Repo** pflegen und in alle Tools symlinken. Die Skills sind reines Markdown — kein Build, keine Runtime, keine Tool-spezifische Konfiguration nötig (außer Symlink-Pfade).

Frontmatter-Felder, die nur ein Tool kennt (z. B. `context: fork` für Claude Code), werden von anderen Tools ignoriert — sie stören nicht. Wir könnten also Claude-Code-spezifische Felder hinzufügen, ohne Cursor/Windsurf/pi.dev zu beeinflussen.

## Referenzen

- [Agent Skills Specification](https://agentskills.io/specification) — offizielle Spec
- [Claude Code Skills Doku](https://code.claude.com/docs/en/skills)
- [Windsurf Cascade Skills Doku](https://docs.windsurf.com/windsurf/cascade/skills)
- [pi.dev Skills Doku](https://pi.dev/docs/latest/skills)
- [Claude Code Skills Complete Guide (2026)](https://duet.so/guides/claude-code-skills-complete-guide)