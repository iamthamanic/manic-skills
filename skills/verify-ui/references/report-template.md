# Report Template

Copy this structure for every verify-ui run. Replace placeholders.

```markdown
## Ergebnis
PASS | PARTIAL | FAIL

## Projekt
- Workspace: `<path>`
- App root: `<path>`
- Stack: `<Vite | Next | …>`
- Playwright: `<existing | bootstrapped | skipped>`

## Technische Basis
- Checks command: `<exact command>`
- Checks result: PASS | FAIL
- E2E command: `<exact command>`
- E2E result: PASS | FAIL | SKIPPED

## Kontext-Quellen
- [ ] `.qa/acceptance/<slug>.md` (from /implement — primary)
- [ ] `.qa/project.yaml`
- [ ] AGENTS.md
- [ ] Styleguide: `<path>`
- [ ] Fallback: git diff / conversation (only if no acceptance file)

## Akzeptanzkriterien
| # | Kriterium | Ergebnis | Evidence |
|---|-----------|----------|----------|
| 1 | … | OK / FAIL | `.qa/evidence/.../01-....png` |

## Edge Cases
| ID | Case | Ergebnis | Anmerkung |
|----|------|----------|-----------|
| E01 | App loads | OK | |
| E08 | Mobile | SKIPPED | reason |

## UX-Bewertung
- Entspricht Iteration/Ticket: ja | teilweise | nein
- Styleguide-Konformität: …
- Verständlichkeit: …
- Console/Network: keine Fehler | …

## Kritische Probleme
Keine.

<!-- oder Bullet-Liste mit Repro-Schritten -->

## Verbesserungen (non-blocking)
Keine.

## Playwright Bootstrap
N/A | Dateien angelegt: `<list>` — bitte committen?

## Empfehlung
Kann weiter zu /review-ticket. | Fix erforderlich: …
```

## Verdict rules

| Verdict | When |
|---------|------|
| **PASS** | Checks green + all critical AC + no critical edge failures |
| **PARTIAL** | Core works; UX/style/minor edge issues |
| **FAIL** | Checks failed OR critical AC failed OR app crash |

## After report

- FAIL → list concrete fixes (component, selector, expected vs actual)
- Do not auto-run `/implement` unless user asks
- Suggest promoting `.qa/runs/*.spec.ts` → `e2e/` when stable
