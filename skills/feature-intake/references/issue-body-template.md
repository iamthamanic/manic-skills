# GitHub issue body template (feature-intake)

Use for every slice. German for user-facing examples when `locale: de`.

```markdown
## Intent
<One paragraph: what this slice delivers>

## User Journey
1. User …
2. System …
3. User sees …

## Problem
<What is missing today; link to epic design>

## Solution
<Approach; files/modules; reuse list>

## Runtime
| Axis | This slice |
|------|------------|
| Local (desktop) | yes / no / partial |
| Cloud session | yes / no / hybrid gate |
| Appwrite Functions | touch / skip |

## Edge Cases
- …
- …

## Acceptance
- [ ] …
- [ ] …

## Design
Epic: `.qa/design/<epic-slug>.md`

## Blockers
Depends on #<issue>   <!-- omit if none -->

## Runner
Labels: P0|P1|P2, needs-design (optional)
Feature slug: `<feature-slug>`
```
