---
name: debug
description: >-
  Reproduce UI and runtime bugs with DevTools MCP (console, network, exceptions),
  Playwright when applicable, and knowledge-base search (RAG, GitHub issues, repo).
  Supports Tauri desktop, web, and api-only projects. Use when the user reports a
  bug, error, crash, console error, or asks to debug, reproduce, or find root cause.
  Triggers: debug, fehler, bug, console error, reproduzieren, root cause, stack trace.
disable-model-invocation: true
---

# Debug

Investigate bugs with **reproducible evidence** before fixing. Project-agnostic global skill.

**Does not ship fixes by default** — output is a debug report. User invokes `@implement` for code changes unless they explicitly ask to fix in the same turn.

## Iron Law

```
NO FIX PROPOSAL WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Do not propose or apply fixes until Step 8 has a evidenced root cause (repro grade ≠ not-reproduced without explicit “cannot reproduce / need artifacts” stop). Symptom patches are failure. Same spirit as [obra systematic-debugging](https://www.skills.sh/obra/superpowers/systematic-debugging) — kept here so ECC still owns the entry point.

## Pipeline position

```
@debug  →  (report)  →  @implement  →  @verify-ticket  →  @verify-ui
```

Also: `@verify-ui` FAIL → `@debug` for root cause before another `@implement` loop.

**Hard bugs** (flake, perf, no red loop, ≥2 failed fixes): follow [references/hard-bugs.md](references/hard-bugs.md) before Step 8 — tight feedback loop first ([Matt diagnose](https://www.skills.sh/mattpocock/skills/diagnose)), then falsifiable hypotheses; after **3 failed fixes** stop and question architecture.

## Global helper skills

| Helper | When in debug |
|--------|----------------|
| `@zoom-out` | Unfamiliar module before deep instrumentation (hard-bugs path) |
| `@verify-ui` | After fix proposed — confirm regression cleared |
| `@documentation-lookup` | Library/framework errors in stack trace |
| `@search-first` | Similar patterns in repo before claiming greenfield bug |
| `@security-review` | Auth, XSS, secrets in network/console evidence |
| `@foundations` | Hard-bugs: ≥3 failed fixes → architecture discussion |

## Workflow checklist

```
Debug Progress:
- [ ] 1. Restate bug — expected vs actual; user steps
- [ ] 2. Discover shell profile (tauri | web | api-only)
- [ ] 3. Load project dev config (.qa/project.yaml, package.json)
- [ ] 4. Ensure dev stack running (or start via Shell)
- [ ] 5. Reproduce (Playwright and/or browser MCP)
- [ ] 5b. Hard path? → references/hard-bugs.md (tight red loop + hypotheses)
- [ ] 6. Collect DevTools evidence (console, network, exceptions)
- [ ] 7. Search knowledge bases (parallel, min 2 sources)
- [ ] 8. Root cause + confidence + minimal fix hint (Iron Law gate)
- [ ] 9. Write report — see references/report-template.md
```

---

## Step 1 — Intake

Capture:

- **Expected** vs **actual** behavior
- **Steps to reproduce** (numbered)
- **First seen** (after which change, if known)
- **Environment** (OS, branch, local vs CI)

If steps are missing, infer from acceptance/git diff — state assumptions.

---

## Step 2 — Shell profile

Read [references/tauri-debug.md](references/tauri-debug.md).

| Profile | Signals |
|---------|---------|
| `tauri` | `src-tauri/`, `tauri.conf.json`, `dev:desktop` in scripts |
| `web` | Vite/Next/CRA, browser dev server |
| `api-only` | No frontend entry — skip browser MCP |

Never hardcode ports — read `.qa/project.yaml` `devCommand` / `devUrl` first, then `package.json` scripts.

---

## Step 3 — Dev stack

1. Check terminals / `devUrl` reachable
2. If not running, start `devCommand` from project config (background Shell)
3. For Tauri: prefer `dev:desktop` over raw Vite when native layer suspected

---

## Step 4 — Reproduce

### Playwright (preferred when e2e exists or UI flow is clear)

Follow `@verify-ui` [playwright-bootstrap.md](../verify-ui/references/playwright-bootstrap.md) detection rules.

- Reuse existing `e2e/*.spec.ts` when scenario exists
- Else create **temporary** `e2e/debug-repro-<slug>.spec.ts`:
  - `trace: 'on'`, screenshot on failure
  - Delete or promote to regression after fix

Run: `npm run test:e2e -- e2e/debug-repro-<slug>.spec.ts` (or project `e2eCommand`)

### Browser MCP (interactive repro)

1. `GetMcpTools` for `cursor-ide-browser` — read schemas before calling
2. `browser_navigate` → `browser_lock` → reproduce steps → `browser_unlock`
3. `browser_snapshot` after each critical step

See [references/mcp-devtools.md](references/mcp-devtools.md) for CDP console/network collection.

---

## Step 5 — DevTools evidence (mandatory for UI bugs)

Use available MCP (never guess tool names):

1. **Primary:** `cursor-ide-browser` → `browser_cdp`
2. **Fallback:** `user-chrome-devtools` — if `needsAuth` or `error`, call `mcp_auth` once, else document fallback

Collect at minimum:

- Console errors/warnings at failure time
- Failed network requests (4xx/5xx, CORS, blocked)
- Uncaught exception stack (first line in app code)
- Screenshot at failure state

---

## Step 6 — Knowledge bases

Read [references/knowledge-sources.md](references/knowledge-sources.md). Run **at least two** in parallel:

- Repo grep (error string, component, route)
- GitHub issues (`gh issue list --search "..."`) when `gh` available
- LightRAG (`mcp__lightrag__query` mode `hybrid`) when server up
- Project `tickets/`, `.qa/edge-cases.md`, `.qa/debug-log.md` if present
- Global ledger: `~/.cursor/skills/debug/ledger/`

Do not claim root cause without correlating evidence + code location.

---

## Step 7 — Root cause

**Iron Law gate:** Do not write a fix proposal here without evidence from Steps 5–6 (and hard-bugs loop if escalated).

State:

- **Root cause** (one paragraph)
- **Confidence:** high | medium | low
- **Repro grade:** full | partial (vite-only) | not-reproduced | api-only
- **Minimal fix** (files/functions, no drive-by refactors) — only after root cause
- **Regression guard** (which e2e/assertion to add)
- **Hard path (if used):** red command, top hypothesis tested, fix-attempt count (stop at ≥3 → architecture)

For Tauri `partial` repros, flag `tauri-native-layer` if `invoke`/FS/permissions likely — see tauri-debug.md.

Hard / flake / perf: [references/hard-bugs.md](references/hard-bugs.md).

---

## Step 8 — Report

Write report using [references/report-template.md](references/report-template.md).

Optional: append solved cases to project `.qa/debug-log.md` or global `ledger/` (user consent for PII).

---

## Anti-patterns

- Fixing without repro evidence (violates Iron Law)
- Opening `http://localhost:3000` in external browser for Tauri-only native bugs and claiming PASS
- Loading every MCP at once — use targeted CDP commands
- Skipping knowledge search when error message is generic
- Leaving `debug-repro-*.spec.ts` orphaned without note in report
- Jumping to hypotheses before a red-capable loop on hard/flake/perf bugs
- Fourth fix attempt without stopping for architecture (`hard-bugs.md` three-strike)
- Installing Matt diagnose / obra systematic-debugging as parallel entry skills — principles live in `hard-bugs.md` only
