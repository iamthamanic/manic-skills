# Issue body template (feature-intake)

**Canonical source:** `@issue-contract` — `~/.claude/skills/issue-contract/references/issue-template.md`
(or `.qa/issue-template.md` project override when present). Do not maintain a separate body shape here.

Resolution snippet:

```bash
if [[ -f ".qa/issue-template.md" ]]; then
  TEMPLATE=".qa/issue-template.md"
else
  TEMPLATE="$HOME/.claude/skills/issue-contract/references/issue-template.md"
fi
```

## feature-intake specifics

- German for user-facing `## Intent` / `## User Journey` examples when `locale: de`.
- Project values (labels, max acceptance bullets, runtime axes) from
  `.qa/project.yaml` → `issueContract` (fallbacks per `@issue-contract`).
- Every slice keeps the mandatory typed-strict acceptance bullet (Boy Scout).
- `## Runtime` rows come from the stack profile (`runner-profile.stackProfile`); omit the
  section entirely for single-runtime projects.
- The create script resolves dependencies into `## Blockers` and appends the
  `<!-- feature-intake slug: <slug> -->` marker after `## Runner`.

Filled example (feature slice, `locale: de`):

```markdown
## Type
feature

## Intent
Nutzer sehen ihre zugewiesenen Zugänge im Profil und Admins können sie pflegen.

## Goal
Access-App-Zuweisungen sind pro User les- und schreibbar; Änderungen triggern Authentik-Group-Sync.

## Non-Goals
- Kein Self-Service für User (nur Admin-UI)
- Keine App-Katalog-Pflege-UI (Katalog bleibt Code)

## Context
- Existing: `backend/app/modules/identity/` — Authentik-Client + Outbox-Worker
- Reuse: `identity-outbox.util.ts` — enqueue-Pattern für GROUPS_SYNC
- Links: `.qa/design/authentik-oidc.md`

## Scope
In:
- `backend/app/modules/identity/services/user-access-apps.service.ts`
- `frontend/src/components/admin/HrKo_AccessAppsFields.tsx`
Out:
- `backend/app/modules/mailbox/**`

## User Journey
1. Admin öffnet Mitarbeiter-Profil
2. System lädt aktuelle App-Zuweisungen
3. Admin speichert Auswahl; Sync läuft asynchron

## Security & Data
- `organizationId`-Guard auf allen Zuweisungs-Queries
- Secure-by-Default: B-02, B-03

## Edge Cases
- Unbekannte App-Keys werden abgelehnt (400)
- Leere Auswahl entfernt alle Gruppen außer Default

## Acceptance
- [ ] GET/PUT `/api/users/:id/access-apps` mit organizationId-Guard
- [ ] PUT löst GROUPS_SYNC-Outbox-Task aus
- [ ] Admin-UI Checkboxen laden + speichern
- [ ] Touched files: zero type escape hatches (typed-strict / Boy Scout)

## Blockers
Depends on #172

## Runner
Labels: P1
Feature slug: `access-apps-admin-ui`
Design: `.qa/design/authentik-oidc.md`
```
