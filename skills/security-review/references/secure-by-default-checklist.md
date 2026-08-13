# Secure-by-Default Checklist

**Kanonische Quelle** für die projektweite „Secure by Default"-Checkliste. Vollständig eingebettet — keine externen Links zur Laufzeit. Wird von `@project-setup` in `AGENTS.md` und von `@implement`, `@audit-changes`, `@ecc-check`, `@review-ticket` referenziert.

> Herkunft: Adaptiert aus Matt Pal's „simple security checklist for your vibe coded apps". Inhalte sind hier dokumentiert und mitgegeben, damit die Pipeline offline-fähig und drift-sicher bleibt.

Diese Checkliste ist **techstack-agnostisch**. Jedes Skill wendet nur die zutreffenden Sektionen auf den jeweiligen Diff an (Frontend-only-Diff → Frontend-Tabelle; Backend-Diff → Backend-Tabelle; Fullstack → beide plus Practical Habits).

---

## Frontend Security

| # | Maßnahme | Beschreibung | Fail if |
|---|----------|--------------|---------|
| F-01 | HTTPS überall verwenden | Verhindert Basis-Eavesdropping und Man-in-the-Middle-Angriffe | App läuft ohne TLS oder mixed content |
| F-02 | Input-Validierung & Sanitization | Verhindert XSS durch Validierung aller User-Inputs | Unvalidierter User-Input erreicht Render- oder State-Schicht |
| F-03 | Keine sensiblen Daten im Browser | Keine Secrets in localStorage oder Client-Code | `localStorage.setItem('token' \| 'secret' \| 'password', …)` im Diff |
| F-04 | CSRF-Schutz | Anti-CSRF-Tokens für Forms und zustandsändernde Requests | State-changing POST/PUT/PATCH ohne CSRF-Token oder SameSite-Cookie |
| F-05 | API-Keys nie im Frontend exponieren | API-Credentials bleiben serverseitig | `apiKey`/`secret` in Client-Bundle, `NEXT_PUBLIC_*` für Secrets verwendet |

---

## Backend Security

| # | Maßnahme | Beschreibung | Fail if |
|---|----------|--------------|---------|
| B-01 | Authentication Fundamentals | Etablierte Libraries, Password-Storage mit Hashing+Salting | Eigenbau-Auth, Plaintext- oder schwache Hashes, unsalted |
| B-02 | Authorization Checks | Berechtigungen immer vor Aktion prüfen | Sensitive Operation ohne Rollen-/Owner-Check |
| B-03 | API-Endpoint-Schutz | Jeder API-Endpoint hat Auth-Middleware | Unauthentifizierter Endpoint auf geschützter Ressource |
| B-04 | SQL-Injection-Prävention | Parameterized Queries oder ORM, niemals Raw-SQL mit User-Input | String-Konkatenation in SQL-Statement, `query(\`…${userInput}\`)` |
| B-05 | Basis Security Headers | X-Frame-Options, X-Content-Type-Options, HSTS konfiguriert | Helm/Headers fehlen oder `unsafe-inline`/`unsafe-eval` ohne Removal-Plan |
| B-06 | DDoS-Schutz | CDN oder Cloud-Service mit DDoS-Mitigation | Rate-Limiting deaktiviert „zum Debuggen", kein Edge-Protection-Layer |
| B-07 | Least-privilege assignment (Grant-/Role-/Bundle-Guard) | Wer Rechte, Rollen, Bundles oder Gruppen zuweist, darf nur das vergeben, was er selbst hält (Superset). Alle Assignment-Pfade prüfen: grants, revokes, **bundles/roles/groups**, Create-User-Defaults | Nur Keys gefiltert, Bundles/Rollen nur Catalog-Whitelist; „mitigated because X.edit only on admin bundle“ ohne Code-Guard |
| B-08 | Deny-by-default AuthZ-Mapping | Unbekannte Route → deny. Mapped Route: Read ≠ Write; Non-GET/HEAD braucht `.edit`/Write-Key oder explizites Deny | Path fest auf `*.view` für PUT/POST/PATCH/DELETE; Write-Feature hinter Read-Key; Default-Fallback auf breites Read-Recht statt null/403 |
| B-09 | Trust-boundary identity | Subject (User-ID, Rollen) nur aus Session/JWT/server-derived Trust — nie aus Client-Headern | `x-user-id` / Role-Header vom Client akzeptiert oder unverändert weitergeleitet |

---

## Practical Security Habits

| # | Maßnahme | Beschreibung | Fail if |
|---|----------|--------------|---------|
| P-01 | Dependencies aktuell | Meiste Vulnerabilities aus veralteten Libraries | `npm audit --audit-level=high` zeigt offene High/Critical |
| P-02 | Korrekte Fehlerbehandlung | Keine sensiblen Details in Fehlermeldungen | Error-Response enthält Stack-Trace, interne Pfade oder Secrets |
| P-03 | Secure Cookies | HttpOnly, Secure, SameSite gesetzt | Session-Cookie ohne HttpOnly oder ohne Secure in Prod |
| P-04 | File-Upload-Sicherheit | Dateityp, Größe prüfen, Malware-Scan | Upload ohne Type/Size-Validierung, Pfad-Traversal möglich |
| P-05 | Rate Limiting | Auf allen API-Endpoints, besonders Auth | Auth-Endpoint ohne Rate-Limit oder Limit deaktiviert |

---

## Severity-Mapping für Reviews

| Checklist-Verstoß | Severity | Skill-Aktion |
|-------------------|----------|--------------|
| F-03, B-01, B-04, B-07, B-08, B-09, P-04 (Critical) | **Critical** | `@review-ticket` blockt ACCEPT; `@ecc-check` BLOCKED |
| F-01, F-04, F-05, B-02, B-03, B-05, P-01, P-03, P-05 | **Important** | Blockt ACCEPT/READY bis fix |
| F-02, B-06, P-02 | **Minor** → Important wenn Trust-Boundary betroffen | Note für später oder fix vor PR |

## RBAC / Permission-Admin Diff Gate (B-07 / B-08 / B-09)

Wenn der Diff User-Management, Bundles, Roles, Permission-APIs, Auth-Middleware oder Route→Permission-Resolver berührt, **immer** manuell prüfen (RG allein reicht nicht):

1. **B-07 — Assignment inventory:** Jedes Feld listen, das effective AuthZ ändert (`grants`, `revokes`, `bundles`, `roles`, `groups`, Templates, Create-Defaults). Pro Feld: Actor darf nur ≤ eigene effective permissions vergeben (Superset). Create (POST) und Update (PUT/PATCH) gleich behandeln.
2. **B-07 — Anti-pattern:** Catalog-Zufall („`users.edit` liegt nur im Admin-Bundle“) ist **keine** Mitigation — Einzel-Grants oder Catalog-Änderungen brechen das.
3. **B-08 — Method matrix:** Für jeden gemappten Mount: GET/HEAD → `.view` ok; state-changing → `.edit`/Write-Key oder deny. Unbekannter Pfad → `null`/403, **kein** Default auf `overview.view`.
4. **B-08 — Feature flags:** Schreib-Flags (z. B. UI-Registry writes) dürfen nicht hinter reinen Read-Keys liegen.
5. **B-09 — Identity:** Subject nur aus Session/JWT/signiertem Server-Trust; Client-Header für User-ID verwerfen.

## RG-Probes (diff-scoped, von `@audit-changes` / `@ecc-check` ausgeführt)

```bash
# F-03: Secrets in localStorage
rg "localStorage\.(set|get)Item\(['\"](token|secret|password|api[_-]?key)" frontend/src
# F-05: API keys in client bundle
rg "NEXT_PUBLIC_.*(SECRET|KEY|PASSWORD|TOKEN)" frontend/ --type ts
# B-04: SQL injection patterns
rg "query\(\`.*\$\{" backend --type ts
# P-02: Sensitive data in logs/errors
rg "console\.(log|error)\(.*(password|secret|token|api[_-]?key)" backend --type ts
# P-03: Insecure cookies
rg "Set-Cookie" backend --type ts | rg -v "HttpOnly|Secure|SameSite"
# P-05: Rate limiting disabled
rg "rateLimit.*disable|skipRateLimit|@ts-ignore.*rate" backend --type ts

# B-07: assignment surfaces (heuristic — always follow with manual Superset check)
rg -n "bundles|user_bundles|assignBundle|roles|user_roles|filterAssignable" --glob '**/api/**/*' -g '!**/node_modules/**'
# B-08: permission resolvers / hardcoded .view (heuristic — check Non-GET branches)
rg -n "resolve.*[Pp]ermission|permissionKey|\.view[\"']" --glob '**/*{permission,auth,middleware}*' -g '!**/node_modules/**'
# B-09: client-controlled identity headers
rg -n "x-user-id|x-user-email|req\.headers\[.user" --glob '**/*.{ts,js}' -g '!**/node_modules/**'
```

Jede Probe mit Match → Critical/Important Finding, dokumentiert im Review-Report.  
Bei B-07/B-08/B-09: Match = **Review-Trigger**; Verdict erst nach Manual Gate oben (nicht nur „Whitelist vorhanden“ → PASS).