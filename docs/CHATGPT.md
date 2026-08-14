# ChatGPT Provider

ChatGPT is a first-class provider in this repository alongside Cursor, Windsurf, pi.dev, and Claude Code.

The shared source of truth remains:

```text
skills/<name>/
  SKILL.md
  references/
  scripts/
  assets/
  agents/openai.yaml   # optional in source; generated during ChatGPT export when absent
```

## Why ChatGPT uses an exporter

Cursor, Windsurf, pi.dev, and Claude Code can load skills from machine-local directories. ChatGPT does not use a local `~/.chatgpt/skills` directory. Its provider adapter therefore generates upload-ready ZIP packages instead of symlinks.

The source skill is not mutated during export.

## Export all skills

```bash
bash scripts/install.sh --chatgpt
```

Equivalent direct command:

```bash
python3 scripts/chatgpt-provider.py export
```

Output:

```text
dist/chatgpt/
  manifest.json
  api-design/
    skill.zip
  audit-changes/
    skill.zip
  ...
```

Each `skill.zip` contains exactly one skill with the skill directory as ZIP root:

```text
api-design/
  SKILL.md
  agents/
    openai.yaml
  ...
```

Upload each ZIP in ChatGPT via **Skills → Create → Upload from your computer**.

## Export selected skills

```bash
python3 scripts/chatgpt-provider.py export --skill api-design
python3 scripts/chatgpt-provider.py export --skill api-design --skill security-review
```

## Verify without keeping packages

```bash
python3 scripts/chatgpt-provider.py verify
```

The repository-wide verifier also runs this check:

```bash
bash scripts/verify.sh
```

## Provider transformations

The ChatGPT adapter deliberately keeps the shared skill source provider-neutral. During export it applies these transformations only inside the generated ZIP:

1. Validate `SKILL.md` and require `name` + `description`.
2. Require the frontmatter `name` to match the source directory name.
3. Rewrite exported `SKILL.md` frontmatter to ChatGPT's portable core fields:
   - `name`
   - `description`
4. Drop provider-specific source frontmatter fields such as Cursor/Claude-specific invocation controls from the ChatGPT copy.
5. Preserve `agents/openai.yaml` when the skill already contains one.
6. Otherwise generate `agents/openai.yaml` with:
   - `interface.display_name`
   - `interface.short_description`
7. Reject symlinks inside a skill package.
8. Enforce a maximum ZIP size of 25 MiB.
9. Generate `dist/chatgpt/manifest.json` with package size and SHA-256 digest.

## Custom ChatGPT metadata

For a skill that needs a custom display name or other OpenAI-specific UI metadata, commit this file into the shared skill directory:

```text
skills/<name>/agents/openai.yaml
```

Example:

```yaml
interface:
  display_name: "API Design"
  short_description: "Design and review production REST API contracts"
```

The exporter preserves a committed `agents/openai.yaml` verbatim. If it is absent, the exporter creates a minimal one only in the generated ChatGPT ZIP.

## All providers

```bash
bash scripts/install.sh --all
```

This performs both provider strategies:

- Cursor → symlinks
- Windsurf → symlinks
- pi.dev → symlinks
- Claude Code → symlinks
- ChatGPT → `dist/chatgpt/<skill>/skill.zip`

## Remove generated ChatGPT artifacts

```bash
bash scripts/install.sh --remove --chatgpt
```

or:

```bash
python3 scripts/chatgpt-provider.py clean
```

The generated `dist/chatgpt/` directory is ignored by Git.

## Important limitation

The repository can prepare, validate, and version ChatGPT-compatible skills, but it cannot automatically install them into a user's ChatGPT account from a local shell script. Upload remains an account/UI operation unless OpenAI exposes a supported installation API in the future.
