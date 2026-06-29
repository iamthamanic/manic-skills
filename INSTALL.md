# Installation

Drei Methoden, je nach Ausgangslage. **Methode A (Symlink)** ist empfohlen, weil `git pull` dann alle Skills aktualisiert.

## Methode A — Symlink (empfohlen)

Repo klonen und `install.sh` ausführen. Das Skript legt für jeden Skill-Ordner einen Symlink von `~/.cursor/skills/<name>` → `<repo>/skills/<name>` an.

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh
```

Voraussetzung: `~/.cursor/skills/` existiert noch nicht oder enthält keine gleichnamigen Ordner, die keine Symlinks sind. Das Skript überschreibt keine echten Ordner — es warnt und überspringt sie. Vorhandene Symlinks werden aktualisiert (`ln -sfn`).

Updates:

```bash
cd ~/repos/manic-skills
git pull
# Symlinks zeigen automatisch auf die neuen Dateien — fertig.
```

Deinstallation:

```bash
bash ~/repos/manic-skills/scripts/install.sh --remove
# entfernt alle Symlinks, die auf dieses Repo zeigen
```

## Methode B — Copy

Wenn du keine Symlinks willst (z. B. weil du Skills unabhängig vom Repo bearbeiten willst):

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
cp -R ~/repos/manic-skills/skills/* ~/.cursor/skills/
```

Nachteil: Updates musst du manuell syncen — `cp -R` überschreibt bei jedem `git pull`.

## Methode C — Direkt nach `~/.cursor/skills` klonen

Wenn `~/.cursor/skills/` noch leer ist oder nicht existiert:

```bash
git clone https://github.com/iamthamanic/manic-skills ~/.cursor/skills
```

Das Repo wird selbst zum Skill-Ordner. Nachteil: du kannst dann keine Skills haben, die nicht im Repo sind, und Updates überschreiben lokale Änderungen.

## Voraussetzungen

- **Cursor** installiert (Desktop-App oder VS-Code-Erweiterung)
- **Bash** (macOS/Linux). Für Windows: Git Bash oder WSL.
- Kein Account-Wechsel nötig — Skills sind maschinenlokal, nicht an den Cursor-Account gebunden.

## Verifikation

Nach der Installation:

```bash
bash ~/repos/manic-skills/scripts/verify.sh
```

Prüft, dass jeder Skill-Ordner eine `SKILL.md` mit gültigem Frontmatter (`name`, `description`) hat und alle Symlinks (Methode A) funktionieren.

## Troubleshooting

| Symptom | Ursache | Fix |
|---------|---------|-----|
| Skill taucht in Cursor nicht auf | Symlink kaputt oder Frontmatter invalid | `verify.sh` laufen lassen; Skill in Cursor via `/skills` prüfen |
| `install.sh` überspringt Ordner | Echter Ordner (kein Symlink) existiert bereits | Backup: `mv ~/.cursor/skills/<name> ~/.cursor/skills/<name>.bak`, dann `install.sh` erneut |
| Nach `git pull` sind Skills weg | Repo wurde an anderer Stelle geklont, Symlinks zeigen auf alte Pfade | `install.sh` erneut ausführen (aktualisiert Symlinks via `ln -sfn`) |
| `disable-model-invocation: true` Skills werden nicht automatisch vorgeschlagen | Das ist beabsichtigt — diese Skills müssen explizit mit `@<name>` aufgerufen werden | Skill manuell aufrufen, z. B. `@ecc-check` |