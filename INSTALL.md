# Installation

Skills funktionieren in **Cursor**, **Windsurf**, **pi.dev**, **Claude Code** und **ChatGPT**. Die ersten vier Provider laden Skills aus lokalen Verzeichnissen; ChatGPT bekommt upload-fertige ZIP-Pakete aus demselben `skills/`-Quellbaum.

## Provider-Ziele

| Tool | Strategie | Ziel |
|------|-----------|------|
| Cursor | Symlink | `~/.cursor/skills/<name>/` |
| Windsurf | Symlink | `~/.codeium/windsurf/skills/<name>/` |
| pi.dev | Symlink | `~/.pi/agent/skills/<name>/` (auch `~/.agents/skills/`) |
| Claude Code | Symlink | `~/.claude/skills/<name>/` |
| ChatGPT | Export | `dist/chatgpt/<name>/skill.zip` |

ChatGPT hat bewusst **kein erfundenes lokales Skill-Verzeichnis**. Der Provider-Adapter erzeugt stattdessen pro Skill ein validiertes Upload-Paket. Details: [`docs/CHATGPT.md`](docs/CHATGPT.md).

## Methode A — Provider-Installer

Repo klonen und `install.sh` ausführen.

**Ein einzelner Provider:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills

bash ~/repos/manic-skills/scripts/install.sh --cursor
bash ~/repos/manic-skills/scripts/install.sh --windsurf
bash ~/repos/manic-skills/scripts/install.sh --pi
bash ~/repos/manic-skills/scripts/install.sh --claude
bash ~/repos/manic-skills/scripts/install.sh --chatgpt
```

Ohne Argument installiert `install.sh` weiterhin nur in Cursor (rückwärtskompatibel).

**Alle fünf Provider parallel:**

```bash
mkdir -p ~/repos
git clone https://github.com/iamthamanic/manic-skills ~/repos/manic-skills
bash ~/repos/manic-skills/scripts/install.sh --all
```

Für Cursor/Windsurf/pi.dev/Claude Code legt das Skript Symlinks an. Für ChatGPT erzeugt es:

```text
dist/chatgpt/
  manifest.json
  <skill>/
    skill.zip
```

Die ChatGPT-ZIPs anschließend in ChatGPT über **Skills → Create → Upload from your computer** hochladen.

## ChatGPT direkt exportieren

Alle Skills:

```bash
python3 ~/repos/manic-skills/scripts/chatgpt-provider.py export
```

Nur ausgewählte Skills:

```bash
python3 ~/repos/manic-skills/scripts/chatgpt-provider.py export --skill api-design
python3 ~/repos/manic-skills/scripts/chatgpt-provider.py export --skill api-design --skill security-review
```

Nur validieren, ohne Export-Artefakte zu behalten:

```bash
python3 ~/repos/manic-skills/scripts/chatgpt-provider.py verify
```

Der Adapter normalisiert die exportierte `SKILL.md` auf `name` + `description`, erzeugt bei Bedarf `agents/openai.yaml`, erhält vorhandene OpenAI-Metadaten, prüft Symlinks und das 25-MiB-Limit und schreibt SHA-256-Hashes in `manifest.json`.

## Updates

Lokale Provider:

```bash
cd ~/repos/manic-skills
git pull
# Symlinks zeigen automatisch auf die neuen Dateien.
```

ChatGPT:

```bash
cd ~/repos/manic-skills
git pull
bash scripts/install.sh --chatgpt
```

Danach die aktualisierten ZIPs erneut in ChatGPT hochladen. Der Repo-Export kann die Skills vorbereiten, aber nicht automatisch in einen ChatGPT-Account installieren.

## Deinstallation / Cleanup

```bash
bash ~/repos/manic-skills/scripts/install.sh --remove
bash ~/repos/manic-skills/scripts/install.sh --remove --cursor
bash ~/repos/manic-skills/scripts/install.sh --remove --chatgpt
bash ~/repos/manic-skills/scripts/install.sh --remove --all
```

Bei ChatGPT entfernt `--remove --chatgpt` nur die lokal generierten Export-Artefakte unter `dist/chatgpt/`; bereits im ChatGPT-Account hochgeladene Skills werden dadurch nicht gelöscht.

## Methode B — Copy für lokale Provider

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

Nachteil: Updates musst du manuell syncen. ChatGPT nutzt weiterhin den Exporter, nicht Copy/Symlink.

## Methode C — Direkt in ein lokales Tool-Verzeichnis klonen

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

Diese Methode gilt nicht für ChatGPT.

## Methode D — pi.dev Settings (ohne Symlink)

pi.dev kann Skills aus beliebigen Verzeichnissen laden:

```json
// ~/.pi/settings.json
{
  "skills": [
    "~/repos/manic-skills/skills"
  ]
}
```

Oder um Skills aus anderen lokalen Tools zu nutzen:

```json
{
  "skills": [
    "~/.cursor/skills",
    "~/.claude/skills",
    "~/.codeium/windsurf/skills"
  ]
}
```

## Voraussetzungen

- Cursor, Windsurf, pi.dev und/oder Claude Code für die jeweiligen lokalen Provider
- Python 3 für den ChatGPT-Provider
- Bash (macOS/Linux). Für Windows: Git Bash oder WSL.

## Verifikation

```bash
bash ~/repos/manic-skills/scripts/verify.sh
```

Prüft:

- jeden Skill-Ordner auf `SKILL.md` + erforderliches Frontmatter,
- Symlinks/Copy-Installationen der vier lokalen Provider,
- die Exportierbarkeit aller Skills für ChatGPT.

## Troubleshooting

| Symptom | Ursache | Fix |
|---------|---------|-----|
| Skill taucht in lokalem Tool nicht auf | Symlink kaputt oder Frontmatter invalid | `verify.sh` laufen lassen |
| `install.sh` überspringt Ordner | Echter Ordner statt Symlink existiert | Ordner sichern/verschieben, dann Installer erneut ausführen |
| Nach `git pull` sind lokale Skills weg | Symlinks zeigen auf alten Repo-Pfad | `install.sh` erneut ausführen |
| ChatGPT-Export schlägt fehl | Ungültiges Frontmatter, Symlink im Skill oder ZIP >25 MiB | `python3 scripts/chatgpt-provider.py verify` ausführen und gemeldeten Skill korrigieren |
| ChatGPT-Skill fehlt nach Export | Export installiert nicht in den Account | `dist/chatgpt/<skill>/skill.zip` in ChatGPT hochladen |
| `disable-model-invocation: true` wird in ChatGPT nicht übernommen | Feld ist provider-spezifisch | ChatGPT-Exporter entfernt fremde Frontmatter-Felder absichtlich |
| `@review-ticket` schlägt in Nicht-Cursor-Tools fehl | Cursor-spezifische Subagents | Tool-eigenen Review verwenden; siehe `docs/TOOL-COMPATIBILITY.md` |
| `@save-prompts-inject` nutzt Cursor-Pfad | Skill hat Cursor-Pfad hardcoded | Provider-spezifischen Pfad/Workflow verwenden |
