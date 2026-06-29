# Local Clone Discovery

Find local copies of starred repos for L3 deep search.

## Config paths

From `~/.cursor/mine-stars.yaml`:

```yaml
localCloneRoots:
  - ~/Desktop/arsvivai/2-DEV-PROJEKTE
  - ~/Projects
```

## Matching algorithm

For star `owner/repo`:

1. Expand `~` in roots
2. Search for directories matching (case-insensitive):
   - `repo` (folder name)
   - `owner-repo`
   - nested `**/repo/.git` with remote containing `owner/repo`
3. Prefer shallow match at root of clone root over deep nesting
4. If multiple matches, prefer one with `package.json` or `.git` remote exact match

**Verify remote:**

```bash
git -C "<path>" remote get-url origin
```

Should contain `owner/repo`.

## When local found

- L2: read README + manifests locally (faster)
- L3: use grep / SemanticSearch in workspace — no GitHub API for file bodies

## When not found

- L2/L3: `gh api repos/OWNER/REPO/readme` or MCP `get_file_contents`
- Note in report: `local: false`

## Performance

Do not scan entire home directory. Only configured `localCloneRoots`, max depth 4 for folder name match.
