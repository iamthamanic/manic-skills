---
name: save-prompts-inject
description: Saves reusable chat prompts to ~/.cursor/prompts/ as Markdown files and injects them into any Cursor conversation. Use when the user says save prompt, use prompt, inject prompt, list prompts, show prompt, delete prompt, or references a saved prompt by name. Works across all projects; optional per-repo overrides in <workspace>/.cursor/prompts/.
---

# Save Prompts and Inject (global)

Personal prompts live in **`~/.cursor/prompts/`** — one file per prompt, Markdown with YAML frontmatter. Applies to **any** Cursor workspace, not a specific repo.

## Storage locations (priority)

| Location | Scope |
|----------|--------|
| `~/.cursor/prompts/` | **Default** — global, all projects |
| `<workspace>/.cursor/prompts/` | **Optional override** — same slug in both → use workspace file |

```
~/.cursor/prompts/
  my-prompt-slug.md
  personal/              # optional subfolder for private prompts

<workspace>/.cursor/prompts/   # only if user wants project-specific prompts
  team-prompt.md
```

## Prompt file format

Create or update `{slug}.md` in the chosen directory:

```markdown
---
name: human-readable-name
description: One line for list/search
tags: [optional, tags]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

Prompt body here. This is what gets injected — instructions, templates, checklists.
```

**Slug rules:** lowercase letters, numbers, hyphens only; max 64 chars. Map `name` → slug: spaces → `-`, strip invalid chars.

## User commands

| User says | Action |
|-----------|--------|
| `save prompt <name>` … | Create or update global file unless user says “in this project” → then workspace path |
| `use prompt <name>` / `inject prompt <name>` | Resolve slug (workspace override, else global); treat body as **primary task** |
| `list prompts` | List global + workspace prompts: slug, description, path, scope |
| `show prompt <name>` | Print full file; do **not** execute |
| `delete prompt <name>` | Remove resolved file; report if missing |

Fuzzy match: if exact slug missing, list close matches and ask once.

## Workflows

### Save

1. Default target: `~/.cursor/prompts/{slug}.md`.
2. If user says “project”, “repo”, or “here” → `<workspace>/.cursor/prompts/{slug}.md` (create dir if needed).
3. Extract prompt text from the message, quoted block, or “save the last message / save above”.
4. Update `updated`; preserve `created` on edits.
5. Confirm with absolute path and ~120 char preview.

### Inject (use)

1. Resolve: workspace ` .cursor/prompts/{slug}.md ` if present, else `~/.cursor/prompts/{slug}.md` (check `personal/` subfolders in both).
2. Inject **body only** (below frontmatter).
3. Execute as the user’s request; append extra text from the same message.
4. Do not dump the full file unless `show prompt`.

### List

```bash
~/.claude/skills/save-prompts-inject/scripts/list-prompts.sh
```

Optional second arg: workspace root for project prompts.

## Rules

- **Never** store secrets (API keys, tokens, passwords) in prompt files.
- Prefer updating an existing slug over near-duplicates.
- This skill is **not** tied to any repository, stack, or product name.
- Global prompts are outside git unless the user dotfiles-syncs `~/.cursor/`.

## Examples

**Save (global)**

> save prompt summarize  
> Summarize the following in 3 bullet points, neutral tone.

→ `~/.cursor/prompts/summarize.md`

**Inject**

> use prompt summarize

**Project-only**

> save prompt deploy-check in this project  
> Run tests, then deploy only if green.

→ `<workspace>/.cursor/prompts/deploy-check.md`

## Scripts

| Script | Purpose |
|--------|---------|
| `~/.claude/skills/save-prompts-inject/scripts/list-prompts.sh` | List global (+ optional workspace) prompts |
| `~/.claude/skills/save-prompts-inject/scripts/validate-prompt.sh` | Validate one file |

Run from any directory; scripts use `$HOME/.cursor/prompts` by default.
