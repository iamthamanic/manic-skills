---
name: mine-stars
description: >-
  Searches the user's GitHub starred repositories for patterns, code, and ideas
  relevant to the current problem or idea in chat — cross-domain, lateral matches
  included. Standalone research skill; not part of pingpong-solution. Use when
  the user says mine-stars, check my stars, starred repos, prior art from stars,
  or wants inspiration from their GitHub stars.
disable-model-invocation: true
---

# Mine Stars

Search **your GitHub starred repositories** for anything useful to **übernehmen**, **inspirieren**, or **referenzieren** for the idea/problem in the current chat.

**Standalone skill.** Not auto-run from `@pingpong-solution`, `@implement`, or `@verify-ui`. **`@pingpong-solution` may suggest** attaching mine-stars when prior art from the user's stars would help — user must invoke explicitly.

**Complements (does not replace):** `@search-first` (repo + web), `@documentation-lookup` (official docs).

**No feature code.** Output is a prior-art research artifact + chat summary.

## When to use

- User attaches `@mine-stars` or asks to search starred repos
- User discusses an idea and wants to know if they already starred something relevant
- Cross-domain inspiration (game repo → workflow pattern for a SaaS tool, etc.)

## When NOT to use

- General GitHub search outside stars (use web search / `search_repositories`)
- Implementing or copying code without license check
- Automatic run during other skills (including `@pingpong-solution` — suggest only, never chain)

---

## Auth & data source (read first)

See [references/github-auth.md](references/github-auth.md).

**Primary:** `gh` CLI (logged-in GitHub account on the machine).

```bash
gh auth status
gh api user/starred --paginate
```

**Secondary:** GitHub MCP `get_file_contents` for README/files when no local clone.

**Not available in GitHub MCP:** listing starred repos — always use `gh` for the star list.

If `gh auth status` fails → stop and tell user how to run `gh auth login`.

---

## Config

Optional `~/.cursor/mine-stars.yaml`:

```yaml
cacheTtlHours: 48
localCloneRoots:
  - ~/Desktop/arsvivai/2-DEV-PROJEKTE
  - ~/Projects
maxL2Repos: 25
maxL3Repos: 8
outputDir: ~/.cursor/prior-art
```

User chat overrides file.

---

## Workflow checklist

```
Mine Stars Progress:
- [ ] Step 0: Verify gh auth + load config
- [ ] Step 1: Extract intent from chat
- [ ] Step 2: Fetch/cache star index (L1)
- [ ] Step 3: Score all stars — cross-domain, concept fit
- [ ] Step 4: L2 shallow on top matches (README, manifest, root tree)
- [ ] Step 5: L3 deep on top 5–8 (local clone or GitHub files)
- [ ] Step 6: Classify each match (übernehmen | inspirieren | Referenz | ignorieren)
- [ ] Step 7: Write prior-art report + chat summary
```

---

## Step 1: Extract intent

From chat (or explicit user query), derive:

1. **Problem / idea** — one paragraph
2. **Capabilities** — 3–7 abstract bullets (not stack-only)
   - e.g. "state machine for workflows", "MCP tool registry", "dependency graph for refactors"
3. **Optional keywords** — for grep fallback

Do **not** over-filter by current project stack. Stars span many domains — lateral matches are valuable.

---

## Step 2: L1 — Star index (all stars)

1. Check cache: `~/.cursor/cache/star-index.json` (refresh if older than `cacheTtlHours`)
2. If stale/missing, fetch:

```bash
gh api graphql -f query='
query($cursor: String) {
  viewer {
    login
    starredRepositories(first: 100, after: $cursor, orderBy: {field: STARRED_AT, direction: DESC}) {
      totalCount
      pageInfo { hasNextPage endCursor }
      nodes {
        nameWithOwner
        description
        url
        stargazerCount
        updatedAt
        primaryLanguage { name }
        repositoryTopics(first: 10) { nodes { topic { name } } }
        licenseInfo { spdxId name }
        isArchived
        isFork
      }
    }
  }
}' --paginate
```

Or REST fallback:

```bash
gh api user/starred --paginate -q '.[] | {full_name, description, html_url, language, topics, license, archived, fork}'
```

Store normalized JSON in cache. Report total star count.

---

## Step 3: Score — cross-domain relevance

For each star, score 0–100 using:

| Signal | Weight |
|--------|--------|
| Capability overlap (semantic, not keyword-only) | high |
| Description / topic match | medium |
| Recency (`updatedAt` within 12 months) | low boost |
| Archived / fork-only | penalty |

Select top **maxL2Repos** (default 25) for L2. Include at least 2–3 **lateral hits** (different domain/language but strong pattern fit) if they score high.

Read [references/scoring-rubric.md](references/scoring-rubric.md).

---

## Step 4: L2 — Shallow

For each L2 candidate:

1. Check local clone under `localCloneRoots` (match `owner/repo` folder names flexibly)
2. If local: read `README.md`, root `package.json` / `pyproject.toml` / `Cargo.toml`, list root dirs (depth 1)
3. If remote only: GitHub MCP `get_file_contents` for `README.md` or use `gh api repos/{owner}/{repo}/readme`
4. Note license from L1

Do not read entire repos at L2.

---

## Step 5: L3 — Deep (top 5–8)

For highest-scoring matches:

- **Local clone:** grep/SemanticSearch for capability keywords; read 1–3 most relevant files
- **Remote:** `get_file_contents` or `gh api` for specific paths surfaced in L2

Cap: **3 files per repo** in the report.

---

## Step 6: Classify matches

| Category | Meaning |
|----------|---------|
| **übernehmen** | npm/pip dependency or small MIT/Apache snippet — name the package |
| **inspirieren** | Architecture/API shape — describe pattern, no blind copy |
| **Referenz** | README/docs worth reading |
| **ignorieren** | Low fit after L2/L3 |

License rules: [references/license-rules.md](references/license-rules.md).

**Never** run `npm install` or copy GPL code without explicit user approval.

---

## Step 7: Output

### Chat

Top 3–5 matches with one line each + link.

### File

Write [references/prior-art-template.md](references/prior-art-template.md) to:

```
~/.cursor/prior-art/<slug>.md
```

Slug: kebab-case from intent (e.g. `mcp-agent-orchestration`, `workflow-state-machine`).

If user explicitly wants it in the workspace: `.qa/design/prior-art-<slug>.md` (optional, not default).

Include sections:

- **Lateral hits** — cross-domain surprises
- **No strong match** — say honestly if nothing scored high

---

## Guardrails

- Standalone — do not mention or invoke pingpong-solution
- No invented repo matches — every match needs evidence (path, README quote, or URL)
- Paginate all stars — do not sample without telling user
- Respect rate limits — use cache, batch L3
- No secrets from starred repos in output
- Do not expose GitHub tokens in reports

## Additional resources

- [references/github-auth.md](references/github-auth.md)
- [references/scoring-rubric.md](references/scoring-rubric.md)
- [references/license-rules.md](references/license-rules.md)
- [references/prior-art-template.md](references/prior-art-template.md)
- [references/local-clone-discovery.md](references/local-clone-discovery.md)
