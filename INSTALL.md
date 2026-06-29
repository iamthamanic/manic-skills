# Installation

Skills funktionieren in **Cursor** und **Windsurf**. Drei Methoden, je nach Ausgangslage. **Methode A (Symlink)** ist empfohlen, weil `git pull` dann alle Skills in beiden Tools aktualisiert.

## Zielverzeichnisse

| Tool | Global (maschinenlokal) | Workspace (projektlokal) |
|------|-------------------------|--------------------------|
| Cursor | `~/.cursor/skills/<name>/` | `<workspace>/.cursor/skills/<name>/` |
| Windsurf | `~/.codeium/windsurf/skills/<name>/` | `<workspace>/.windsurf/skills/<name>/` |

Dieses Repo installiert Skills in die **globalen** Verzeichnisse — sie gelten für alle Projekte auf der Maschine. Für projektlokale Skills kopiere die jeweiligen Ordner nach `<workspace>/.cursor/skills/` bzw. `<workspace>/.windsurf/skills/`.

## Methode A — Symlink (empfohlen)

Repo klonen und `install.sh` ausführen. Das Skript legt für jeden Skill-Ordner einen Symlink vom Tool-Verzeichnis → `<repo>/skills/<name>` an.

**Nur Cursor:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --cursor
```

**Nur Windsurf:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --windsurf
```

**Beide Tools parallel:**

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
# Symlinks zeigen automatisch auf die neuen Dateien — fertig, in beiden Tools.
```

Deinstallation:

```bash
bash ~/repos/manic-skills/scripts/install.sh --remove          # beide Tools
bash ~/repos/manic-skills/scripts/install.sh --remove --cursor  # nur Cursor
bash ~/repos/manic-skills/scripts/install.sh --remove --windsurf # nur Windsurf
```

## Methode B — Copy

Wenn du keine Symlinks willst (z. B. weil du Skills unabhängig vom Repo bearbeiten willst):

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills

# Cursor
cp -R ~/repos/manic-skills/skills/* ~/.cursor/skills/

# Windsurf
mkdir -p ~/.codeium/windsurf/skills
cp -R ~/repos/manic-skills/skills/* ~/.codeium/windsurf/skills/
```

Nachteil: Updates musst du manuell syncen — `cp -R` überschreibt bei jedem `git pull`.

## Methode C — Direkt in ein Tool-Verzeichnis klonen

Wenn das Zielverzeichnis noch leer ist oder nicht existiert:

```bash
# Cursor
git clone https://github.com/iamthamanic/manic-skills ~/.cursor/skills

# Windsurf
mkdir -p ~/.codeium/windsurf
git clone https://github.com/iamthamanic/manic-skills ~/.codeium/windsurf/skills
```

Das Repo wird selbst zum Skill-Ordner. Nachteil: du kannst dann keine Skills haben, die nicht im Repo sind, und Updates überschreiben lokale Änderungen. Für das jeweils andere Tool musst du Methode A oder B verwenden.

## Voraussetzungen

- **Cursor** und/oder **Windsurf** installiert
- **Bash** (macOS/Linux). Für Windows: Git Bash oder WSL.
- Kein Account-Wechsel nötig — Skills sind maschinenlokal, nicht an den Tool-Account gebunden.

## Verifikation

Nach der Installation:

```bash
bash ~/repos/manic-skills/scripts/verify.sh
```

Prüft, dass jeder Skill-Ordner eine `SKILL.md` mit gültigem Frontmatter (`name`, `description`) hat und alle Symlinks (Methode A) in **beiden** Tool-Verzeichnissen funktionieren. Nicht installierte Tools werden übersprungen mit einem Hinweis.

## Troubleshooting

| Symptom | Ursache | Fix |
|---------|---------|-----|
| Skill taucht in Cursor/Windsurf nicht auf | Symlink kaputt oder Frontmatter invalid | `verify.sh` laufen lassen; Skill im Tool via `/skills` bzw. Cascade-Panel prüfen |
| `install.sh` überspringt Ordner | Echter Ordner (kein Symlink) existiert bereits | Backup: `mv ~/.cursor/skills/<name> ~/.cursor/skills/<name>.bak`, dann `install.sh` erneut |
| Nach `git pull` sind Skills weg | Repo wurde an anderer Stelle geklont, Symlinks zeigen auf alte Pfade | `install.sh` erneut ausführen (aktualisiert Symlinks via `ln -sfn`) |
| `disable-model-invocation: true` Skills werden in Windsurf automatisch vorgeschlagen | Windsurf kennt dieses Feld nicht und ignoriert es | Skill manuell aufrufen (`@ecc-check` etc.) — siehe [`docs/WINDSURF-COMPATIBILITY.md`](docs/WINDSURF-COMPATIBILITY.md) |
| `@review-ticket` schlägt in Windsurf fehl | Ruft `@review-bugbot`/`@review-security` auf (Cursor-subagents, in Windsurf nicht verfügbar) | Subagent-Aufrufe manuell durch Windsurf-Review ersetzen oder weglassen — siehe `docs/WINDSURF-COMPATIBILITY.md` |
| `@save-prompts-inject` speichert nach `~/.cursor/prompts/` | Skill hat Cursor-Pfad hardcoded | Für Windsurf: Pfad auf `~/.codeium/windsurf/prompts/` anpassen (fork oder manuell) |