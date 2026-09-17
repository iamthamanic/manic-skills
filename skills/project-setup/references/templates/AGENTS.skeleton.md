# AGENTS.md — {{PROJECT_NAME}}

Dieses Dokument ist die **verbindliche Projektkarte** für Menschen und KI-Agenten.
Lies es zuerst, bevor du Code änderst.

## Was ist dieses Projekt?

<!-- 2–4 Sätze: product summary. Link to docs/PRD.md for detail. -->

**PRD:** [docs/PRD.md](docs/PRD.md)

### Was dieses Repo **ist**

- 

### Was dieses Repo **nicht** ist

- 

---

## Tech Stack (verbindlich)

| Bereich | Technologie | Notiz |
|---------|-------------|-------|
| Frontend | {{FRONTEND_STACK}} | |
| Backend | {{BACKEND_STACK}} | |
| Styling | {{STYLING}} | |
| Tests | {{TESTS}} | |
| Deployment | {{DEPLOY}} | |

**Nicht verwenden:** <!-- forbidden tools/frameworks -->

---

## Architektur

```
{{APP_ROOT}}/
├── …
```

### Schichtenregeln

1. <!-- e.g. game logic has no React imports -->
2. 
3. 

---

## Sprache & Naming

| Bereich | Sprache |
|---------|---------|
| UI (Labels, Fehler) | {{LOCALE_UI}} |
| Code, Commits | Englisch |

---

## Validation

- **Checks:** `npm run checks`
- **Dev:** `npm run dev` → {{DEV_URL}}
- **E2E:** `npm run test:e2e` (Playwright via @verify-ui when ready)

Run checks before push. Do not bypass hooks.

---

## UI / Design

- Styleguide: [docs/UI_STYLEGUIDE.md](docs/UI_STYLEGUIDE.md)
- Use existing components before adding new ones
- Required states: loading, empty, error, disabled where applicable

---

## Issue Template (verbindlich)

Alle Issues folgen dem kanonischen Template aus **`@issue-contract`**
(global: `~/.claude/skills/issue-contract/references/issue-template.md`).
Projekt-Override (nur bei Bedarf): `.qa/issue-template.md` — ersetzt das globale Template vollständig.
Projekt-Werte (Labels, Runtime-Achsen, Locale): `.qa/project.yaml` → `issueContract`.

Pflicht-Sektionen in Reihenfolge: `Type → Intent → Goal → Non-Goals → Context → Scope → User Journey → Runtime → Security & Data → Edge Cases → Acceptance → Blockers → Runner`.

---

## Security Checklist (Secure by Default)

Diese Checkliste ist **techstack-agnostisch** und für alle Agents verbindlich. Vollständige Quelle mit Severity-Mapping und RG-Probes: `~/.claude/skills/security-review/references/secure-by-default-checklist.md` (Inhalte eingebettet, keine externe Links).

Jede Feature-Implementierung muss die zutreffenden Sektionen abhaken. `@implement` dokumentiert die Coverage in der Acceptance-Datei, `@audit-changes`/`@ecc-check` führen diff-scoped Probes aus, `@review-ticket` prüft die Coverage im Verdict. Hop-Ketten (Producer→Consumer, Bulk+Side-Effect) zusätzlich über `@composition-gate` — FLAGGED muss gefixt werden.

### Frontend Security

| # | Maßnahme | Fail if |
|---|----------|---------|
| F-01 | HTTPS überall | App läuft ohne TLS oder mixed content |
| F-02 | Input-Validierung & Sanitization | Unvalidierter User-Input erreicht Render-/State-Schicht |
| F-03 | Keine sensiblen Daten im Browser | `localStorage.setItem('token'\|'secret'\|'password', …)` im Diff |
| F-04 | CSRF-Schutz | State-changing Request ohne CSRF-Token oder SameSite-Cookie |
| F-05 | API-Keys nie im Frontend | Secrets in Client-Bundle, `NEXT_PUBLIC_*` für Secrets |

### Backend Security

| # | Maßnahme | Fail if |
|---|----------|---------|
| B-01 | Authentication Fundamentals | Eigenbau-Auth, Plaintext- oder schwache/unsalted Hashes |
| B-02 | Authorization Checks | Sensitive Operation ohne Rollen-/Owner-Check |
| B-03 | API-Endpoint-Schutz | Unauthentifizierter Endpoint auf geschützter Ressource |
| B-04 | SQL-Injection-Prävention | String-Konkatenation in SQL-Statement mit User-Input |
| B-05 | Basis Security Headers | Headers fehlen oder `unsafe-inline`/`unsafe-eval` ohne Removal-Plan |
| B-06 | DDoS-Schutz | Rate-Limiting deaktiviert, kein Edge-Protection-Layer |
| B-07 | Least-privilege assignment | Bundles/Rollen nur Whitelist; Actor kann mehr vergeben als er hält |
| B-08 | Deny-by-default AuthZ map | Non-GET hinter `*.view`; unbekannter Pfad → Default-Read statt deny |
| B-09 | Trust-boundary identity | User-ID/Rollen aus Client-Headern |
| B-10 | Secrets fail-closed | `process.env.SECRET \|\| 'default-…'`; bestehender unsicherer Fallback zählt nicht als Fix |

### Practical Security Habits

| # | Maßnahme | Fail if |
|---|----------|---------|
| P-01 | Dependencies aktuell | `npm audit --audit-level=high` zeigt offene High/Critical |
| P-02 | Korrekte Fehlerbehandlung | Error-Response enthält Stack-Trace, interne Pfade oder Secrets |
| P-03 | Secure Cookies | Session-Cookie ohne HttpOnly oder ohne Secure in Prod |
| P-04 | File-Upload-Sicherheit | Upload ohne Type/Size-Validierung, Pfad-Traversal möglich |
| P-05 | Rate Limiting | Auth-Endpoint ohne Rate-Limit oder Limit deaktiviert |
| P-06 | Side-effect jobs / Outbox / Fan-out | N identische externe Sends; nicht-atomarer Worker-Claim; Queue-Starvation durch terminale `failed`; `processing` ohne Recovery |

Critical-Verstöße (F-03, B-01, B-04, B-07, B-08, B-09, B-10, P-04) blocken PR/READY. Important-Verstöße (inkl. P-06) blocken ACCEPT/READY bis fix. Worker/Outbox/Bulk-Send im Diff: `@review-bugbot` Pflicht; Skip = Prozess-BLOCK.

---

## QA Pipeline

```
@pingpong-solution  →  @implement  →  @verify-ticket  →  @composition-gate  →  @verify-ui  →  @review-ticket
```

- Design artifacts: `.qa/design/`
- Acceptance: `.qa/acceptance/` (auto-generated by @implement)
- Project config: `.qa/project.yaml`
- Issue template: `@issue-contract` (global canonical; project override via `.qa/issue-template.md`, values via `.qa/project.yaml` → `issueContract`)
- Living docs: `@memory-live-doc` (see below; also via `@ecc-check` / `@commit-push-safe`)
- Composition: `@composition-gate` — hop-chain meaning (cardinality, fallback, concurrent consumers). **FLAGGED findings must be fixed** before review ACCEPT / ecc-check READY / PR. `@implement` must write paths so this gate CLEARs. `@commit-pr-safe` / `@pr-merge-safe` run the gate or accept a same-SHA proof.

### Ponytail (lazy senior dev) — optional

Only include when `enablePonytail: true` in `.qa/setup-profile.yaml` or user requests it.

Reference: [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT). Agent behavior, not app code.

| Phase | Role |
|-------|------|
| `@pingpong-solution` | Rung 1 (YAGNI): include a „do not build“ option |
| `@implement` | 6-rung ladder before code; smallest clean diff |
| `@project-setup` | This subsection (once) |

**Project rules override Ponytail.** Architecture boundaries, security, tests, and accessibility are never skipped.

---

## Development Workflow

### Context compact & long queues (mandatory)

Auto-compact is **unreliable** (often mid-ticket, drops paths/partial state). Do **not** wait for the window to hard-fail.

**After every shipped issue** in a multi-ticket loop (`@ecc-runner-loop` or any N>1 queue):

1. Update the handoff file (path from loop prompt / `@handoff`, else OS temp) with: last merged issue/PR/SHA, next issue number + title. Set `paused: false` only if continuing immediately after compact in the same chat.
2. **Stop the turn** and tell the user to run `/compact` (or open a fresh chat and `@… continue` with the handoff). Prefer `@strategic-compact` for when/how to compact. Do **not** claim the next issue in the same turn.
3. Resume the next ticket only **after** the user continues post-compact (or in the new chat with handoff loaded).

**Never compact mid-implementation** of the current issue (verify → PR → merge must stay in one context).

**Never** treat leftover CI poll / babysit timeouts as blockers; only open PRs and current default-branch HEAD matter.

---

## Living documentation

After material changes, run `@memory-live-doc` (or rely on `@implement` / `@ecc-check` / `@commit-push-safe` / `@project-setup` integration).

- Do not invent features in docs without evidence.
- Storage: `.project-memory/` (bilingual DE+EN JSON; human docs under `docs/` + `docs/en/`).
- Interactive viewer: `docs/memory-live-doc/` (local `/memory-live-doc/`; GitHub Pages/Sites opt-in only).
- Open locally: `@memory-live-doc serve` → `http://127.0.0.1:8765/memory-live-doc/`.
- First setup: `@project-setup` Step 9 or `@memory-live-doc bootstrap`.

---

## README

Keep README in sync when adding features, scripts, or env vars.
