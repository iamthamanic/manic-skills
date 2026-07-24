# {{PROJECT_NAME}} — project-specific edge cases for verify-ui

Extends the universal matrix in the verify-ui skill.
Add rows as features ship.

## Global

| ID | Case | Fail if |
|----|------|---------|
| G-01 | App loads | Blank screen, uncaught console errors |
| G-02 | Locale | UI language does not match AGENTS.md ({{LOCALE}}) |

## Security (Secure-by-Default Seeds)

Seed-Edge-Cases aus der Secure-by-Default-Checkliste (siehe AGENTS.md §Security). Pro Feature ergänzen, sobald zutreffend.

| ID | Case | Fail if |
|----|------|---------|
| S-01 | Secret im Client | `localStorage`/Client-Bundle enthält Token/Secret/Password |
| S-02 | XSS über User-Input | Unvalidierter User-Input wird gerendert ( dangerouslySetInnerHTML o.ä.) |
| S-03 | IDOR / fehlende Authz | Sensitive Ressource ohne Owner-/Rollen-Check erreichbar |
| S-04 | SQL-Injection | Raw-SQL mit User-Input via String-Konkatenation |
| S-05 | Insecure Cookie | Session-Cookie ohne HttpOnly+Secure+SameSite in Prod |
| S-06 | Upload ohne Validierung | File-Upload akzeptiert beliebigen Typ/Größe |
| S-07 | Auth-Endpoint ohne Rate-Limit | Login/Register ohne Rate-Limiting |
| S-08 | Secrets in Logs | `console.log`/Error enthält Password/Token/API-Key |

## <!-- Feature area 1 -->

| ID | Case | Fail if |
|----|------|---------|
| | | |

## <!-- Feature area 2 -->

| ID | Case | Fail if |
|----|------|---------|
| | | |
