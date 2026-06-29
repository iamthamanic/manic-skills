# GitHub Auth for mine-stars

How Cursor/agents access your GitHub stars on this machine.

## What works today (verified)

### 1. GitHub CLI (`gh`) — **use this for stars**

| Item | Value |
|------|-------|
| Binary | `/opt/homebrew/bin/gh` |
| Account | `iamthamanic` |
| Host | `github.com` |
| Token storage | macOS keyring (`gh auth login`) |
| Scopes | `gist`, `read:org`, `repo`, `workflow` |
| Stars API | Works — `gh api user/starred` / GraphQL `starredRepositories` |
| Star count | ~126 (check with GraphQL `totalCount`) |

**Login / refresh:**

```bash
gh auth status
gh auth login   # if not logged in
```

**Why mine-stars prefers `gh`:** The GitHub MCP server has **no tool to list starred repositories**. Only `gh` exposes `user/starred` cleanly with pagination.

---

### 2. Cursor GitHub MCP — **file reads, not star list**

| Item | Location |
|------|----------|
| Config file | `~/.cursor/mcp.json` → `"github"` server |
| Server package | `@modelcontextprotocol/server-github` |
| Env var | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| Cursor MCP id | `user-github` (in agent tool list) |

**Tools useful for mine-stars:** `get_file_contents`, `search_code` (scoped queries)

**Limitation:** No `list_starred_repos` tool in MCP.

**Token check:** Open `~/.cursor/mcp.json` and ensure `GITHUB_PERSONAL_ACCESS_TOKEN` is a **real** PAT, not a placeholder. If MCP file reads fail with 401, create a token at:

https://github.com/settings/tokens

Suggested scopes for mine-stars via MCP: `repo` (private READMEs), or `public_repo` (public only).

`gh` and MCP can use **different** tokens — they are independent auth paths.

---

### 3. Cursor IDE GitHub sign-in (optional)

Cursor may also link GitHub for Cloud Agents / Bugbot / PR features:

**Cursor Settings → Account / Integrations → GitHub**

This is separate from `gh` and MCP. It does **not** automatically give agents your star list. For `@mine-stars`, rely on **`gh`**.

---

## Pre-flight (agent runs at Step 0)

```bash
gh auth status
```

| Result | Action |
|--------|--------|
| Logged in | Proceed with star fetch |
| Not logged in | Tell user: run `gh auth login`, then retry `@mine-stars` |
| Wrong account | `gh auth switch` or re-login |

Optional MCP check:

- Try `get_file_contents` on a known public repo README
- If 401 → note in report: "MCP token invalid; using gh api for file reads"

---

## Fetch commands (copy-paste)

**GraphQL (rich metadata, paginated):**

```bash
gh api graphql -f query='query { viewer { login starredRepositories(first: 100) { totalCount nodes { nameWithOwner description url updatedAt primaryLanguage { name } licenseInfo { spdxId } repositoryTopics(first: 10) { nodes { topic { name } } } isArchived } } } }'
```

**REST (simple list):**

```bash
gh api user/starred --paginate
```

**Single repo README (no MCP):**

```bash
gh api repos/OWNER/REPO/readme --jq .content | base64 -d
```

---

## Cache

After L1 fetch, write:

```
~/.cursor/cache/star-index.json
```

Include: `fetchedAt`, `login`, `totalCount`, `repos[]`.

Refresh when older than `cacheTtlHours` (default 48) or user says "refresh stars".
