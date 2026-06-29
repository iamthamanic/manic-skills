# Cross-Domain Matrix

Score the **recommended option** before finalizing. One line rationale per cell.

| Domain | Key question | ✅ | ⚠️ | ❌ |
|--------|--------------|----|----|-----|
| **KISS** | Smallest solution that solves the stated problem? | | | |
| **SOLID** | Single responsibility per module? Open for extension without modifying core? | | | |
| **DRY** | Reuses existing tokens, types, components, services? | | | |
| **Security** | Input validated? No secrets client-side? Authz on server if needed? XSS/injection considered? | | | |
| **UI/UX** | Loading/empty/error/disabled? Accessible? Matches styleguide? Correct UI language? | | | |
| **Scaling** | Works at 10× data/users? Bundle size OK? P2P/multiplayer path later? | | | |
| **Testability** | Engine unit-testable? UI verifiable via verify-ui acceptance? | | | |
| **Maintainability** | Clear boundaries? Documented in design artifact? No clever one-offs? | | | |

## Verdict rules

- Any **❌ Security** → cannot recommend YES for `/implement` without mitigation plan
- Two or more **❌** → revise option or pick alternative
- **⚠️** items → list in Open Questions; cap confidence at 85%

## Domain equivalents (mental model)

| Code principle | Other domains |
|----------------|---------------|
| Single Responsibility | UX: one primary action per screen |
| Open/Closed | Security: extend via policy hooks, don't patch ad hoc |
| DRY | UX: reuse primitives from design system |
| Dependency Inversion | Architecture: UI depends on engine interface, not internals |
