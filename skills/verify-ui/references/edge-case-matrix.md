# Edge-Case Matrix

Apply the **relevant subset** for each verify-ui run. Document skipped cases in the report.

## Universal (most web apps)

| ID | Case | How to test | Fail if |
|----|------|-------------|---------|
| E01 | App loads | Navigate to `/` | Blank screen, unhandled error overlay |
| E02 | Console clean | Listen for `pageerror` / console `error` | Uncaught exceptions on load |
| E03 | Critical nav | Click main nav items | 404, crash, wrong view |
| E04 | Loading state | Slow network or first paint | Infinite spinner |
| E05 | Empty state | List with no data | Broken layout, missing copy |
| E06 | Error state | Invalid route or failed action | White screen, no feedback |
| E07 | Disabled controls | Buttons that should be disabled | Click causes action |
| E08 | Mobile viewport | 390×844 | Overflow, unreadable text, tap targets too small |
| E09 | Desktop viewport | 1280×720 | Layout broken at wide width |
| E10 | Keyboard | Tab to primary actions | No focus ring, unreachable controls |
| E11 | Reduced motion | `prefers-reduced-motion: reduce` | Violent animation only path |

## Forms & input

| ID | Case | Fail if |
|----|------|---------|
| F01 | Submit empty required fields | No validation message |
| F02 | Invalid input | Crash or silent fail |
| F03 | Success feedback | User unsure action worked |

## Modals & overlays

| ID | Case | Fail if |
|----|------|---------|
| M01 | Open / close modal | Backdrop stuck, body scroll broken |
| M02 | Escape closes | Trap without alternative |
| M03 | Focus trap | Focus escapes to background |

## Auth (if project has login)

| ID | Case | Fail if |
|----|------|---------|
| A01 | Logged out access | Protected route exposed |
| A02 | Wrong credentials | Leaks stack trace or unclear message |

## Async / multiplayer (games, dashboards)

| ID | Case | Fail if |
|----|------|---------|
| S01 | Bot / async turn | UI frozen, duplicate actions |
| S02 | Rapid clicks | Double submit, corrupt state |
| S03 | Mid-action navigation | Crash or stale state |

## Project overrides

If `.qa/edge-cases.md` exists, its cases **override or extend** this list for that repo.

## Mapping to Playwright

```ts
// Mobile
await page.setViewportSize({ width: 390, height: 844 });

// Reduced motion
await page.emulateMedia({ reducedMotion: 'reduce' });

// Console errors
const errors: string[] = [];
page.on('pageerror', (e) => errors.push(e.message));
```

## Severity

- **Critical** — blocks core flow → FAIL
- **Major** — bad UX, workaround exists → PARTIAL
- **Minor** — polish → note in report, may still PASS
