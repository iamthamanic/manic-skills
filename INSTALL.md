# Installation

Skills funktionieren in **Cursor**, **Windsurf**, **pi.dev** und **Claude Code**. Drei Methoden, je nach Ausgangslage. **Methode A (Symlink)** ist empfohlen, weil `git pull` dann alle Skills in allen Tools aktualisiert.

## Zielverzeichnisse

| Tool | Global (maschinenlokal) | Workspace (projektlokal) |
|------|-------------------------|--------------------------|
| Cursor | `~/.cursor/skills/<name>/` | `<workspace>/.cursor/skills/<name>/` |
| Windsurf | `~/.codeium/windsurf/skills/<name>/` | `<workspace>/.windsurf/skills/<name>/` |
| pi.dev | `~/.pi/agent/skills/<name>/` (auch `~/.agents/skills/`) | `<workspace>/.pi/skills/<name>/` (auch `<workspace>/.agents/skills/`) |
| Claude Code | `~/.claude/skills/<name>/` | `<workspace>/.claude/skills/<name>/` |

Dieses Repo installiert Skills in die **globalen** Verzeichnisse — sie gelten für alle Projekte auf der Maschine. Für projektlokale Skills kopiere die jeweiligen Ordner nach `<workspace>/.<tool>/skills/`.

## Methode A — Symlink (empfohlen)

Repo klonen und `install.sh` ausführen. Das Skript legt für jeden Skill-Ordner einen Symlink vom Tool-Verzeichnis → `<repo>/skills/<name>` an.

**Ein einzelnes Tool:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills

bash ~/repos/manic-skills/scripts/install.sh --cursor    # nur Cursor
bash ~/repos/manic-skills/scripts/install.sh --windsurf  # nur Windsurf
bash ~/repos/manic-skills/scripts/install.sh --pi        # nur pi.dev
bash ~/repos/manic-skills/scripts/install.sh --claude    # nur Claude Code
```

**Alle vier Tools parallel:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --all
```

Ohne Argument installiert `install.sh` defaultmäßig nur in Cursor (rückwärtskompatibel).

Voraussetzung: das Zielverzeichnis existiert noch nicht oder enthält keine gleichnamigen Ordner, die keine Symlinks sind. Das Skript überschreibt keine echten Ordner — es warnt und überspringt sie. Vorhandene Symlinks werden aktualisiert (`ln -sfn`).

Updates:

```bash
cd ~/repos/manic-skills
git pull
# Symlinks zeigen automatisch auf die neuen Dateien — fertig, in allen Tools.
```

Deinstallation:

```bash
bash ~/repos/manic-skills/scripts/install.sh --remove          # alle Tools
bash ~/repos/manic-skills/scripts/install.sh --remove --cursor  # nur Cursor
bash ~/repos/manic-skills/scripts/install.sh --remove --all     # alle Tools
```

## Methode B — Copy

Wenn du keine Symlinks willst:

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills

# Cursor
cp -R ~/repos/manic-skills/skills/* ~/.cursor/skills/

# Windsurf
mkdir -p ~/.codeium/windsurf/skills
cp -R ~/repos/manic-skills/skills/* ~/.codeium/windsurf/skills/

# pi.dev
mkdir -p ~/.pi/agent/skills
cp -R ~/repos/manic-skills/skills/* ~/.pi/agent/skills/

# Claude Code
mkdir -p ~/.claude/skills
cp -R ~/repos/manic-skills/skills/* ~/.claude/skills/
```

Nachteil: Updates musst du manuell syncen — `cp -R` überschreibt bei jedem `git pull`.

## Methode C — Direkt in ein Tool-Verzeichnis klonen

Wenn das Zielverzeichnis noch leer ist:

```bash
# Cursor
git clone https://github.com/iamthamanic/manic-skills ~/.cursor/skills

# Windsurf
mkdir -p ~/.codeium/windsurf
git clone https://github.com/iamthamanic/manic-skills ~/.codeium/windsurf/skills

# pi.dev
mkdir -p ~/.pi/agent
git clone https://github.com/iamthamanic/manic-skills ~/.pi/agent/skills

# Claude Code
mkdir -p ~/.claude
git clone https://github.com/iamthamanic/manic-skills ~/.claude/skills
```

Das Repo wird selbst zum Skill-Ordner. Nachteil: du kannst dann keine Skills haben, die nicht im Repo sind. Für das jeweils andere Tool musst du Methode A oder B verwenden.

## Methode D — pi.dev Settings (ohne Symlink)

pi.dev kann Skills aus beliebigen Verzeichnissen laden, über Settings-Konfiguration:

```json
// ~/.pi/settings.json
{
  "skills": [
    "~/repos/manic-skills/skills"
  ]
}
```

Oder um Skills aus anderen Tools zu nutzen:

```json
{
  "skills": [
    "~/.cursor/skills",
    "~/.claude/skills",
    "~/.codeium/windsurf/skills"
  ]
}
```

Vorteil: kein Symlink nötig, pi.dev lädt direkt aus dem Repo. Nachteil: nur pi.dev-spezifisch, andere Tools brauchen weiterhin ihre eigenen Installationen.

## Voraussetzungen

- **Cursor**, **Windsurf**, **pi.dev** und/oder **Claude Code** installiert
- **Bash** (macOS/Linux). Für Windows: Git Bash oder WSL.
- Kein Account-Wechsel nötig — Skills sind maschinenlokal, nicht an den Tool-Account gebunden.

## Verifikation

Nach der Installation:

```bash
bash ~/repos/manic-skills/scripts/verify.sh
```

Prüft, dass jeder Skill-Ordner eine `SKILL.md` mit gültigem Frontmatter (`name`, `description`) hat und alle Symlinks in **allen vier** Tool-Verzeichnissen funktionieren. Nicht installierte Tools werden übersprungen mit einem Hinweis.

## Troubleshooting

| Symptom | Ursache | Fix |
|---------|---------|-----|
| Skill taucht in Tool nicht auf | Symlink kaputt oder Frontmatter invalid | `verify.sh` laufen lassen; Skill im Tool via `/skills` bzw. `/skill:name` prüfen |
| `install.sh` überspringt Ordner | Echter Ordner (kein Symlink) existiert bereits | Backup: `mv ~/.cursor/skills/<name> ~/.cursor/skills/<name>.bak`, dann `install.sh` erneut |
| Nach `git pull` sind Skills weg | Repo wurde an anderer Stelle geklont, Symlinks zeigen auf alte Pfade | `install.sh` erneut ausführen (aktualisiert Symlinks via `ln -sfn`) |
| `disable-model-invocation: true` Skills werden in Windsurf automatisch vorgeschlagen | Windsurf kennt dieses Feld nicht und ignoriert es | Skill manuell aufrufen — siehe [`docs/TOOL-COMPATIBILITY.md`](docs/TOOL-COMPATIBILITY.md) |
| `@review-ticket` schlägt in Nicht-Cursor-Tools fehl | Ruft `@review-bugbot`/`@review-security` auf (Cursor-subagents) | Subagent-Aufrufe manuell durch Tool-eigenen Review ersetzen — siehe `docs/TOOL-COMPATIBILITY.md` |
| `@save-prompts-inject` speichert nach `~/.cursor/prompts/` | Skill hat Cursor-Pfad hardcoded | Pfad anpassen oder Symlink: `ln -sfn ~/.pi/agent/prompts ~/.cursor/prompts` |
| pi.dev findet Skills nicht | Falsches Verzeichnis oder Settings nicht konfiguriert | `install.sh --pi` verwenden oder `~/.pi/settings.json` mit `skills`-Array konfigurieren |