# Quality gates (visual QA)

Implementation is **not done** until verification matches task scale. Prefer evidence over vibes.

## Tool preference

| Available | Use |
|-----------|-----|
| `@verify-ui` + Playwright | Browser flows + screenshots → `.qa/evidence/` |
| `@web-design-guidelines` | Static Web Interface Guidelines + Adaptive soft checks |
| Browser MCP / DevTools | Exploratory + a11y tree spot-checks |
| `@mobile-performance-audit` | Capacitor/mobile shell |
| `@test-performance-speed` | Journey bottlenecks (measure first) |
| `@test-gate` | Lint/tsc/build — does **not** replace visual QA |
| None of the above | Manual checklist below; mark gaps **UNVERIFIED** |

Never claim WCAG conformance solely from an automated scan.

## Three passes (minimum for non-trivial UI)

### Pass 1 — Visual design & layout

- [ ] Type hierarchy readable  
- [ ] Spacing/alignment consistent with system  
- [ ] Color/contrast coherent; accent locked  
- [ ] Proportions sensible; no accidental overflow/clip  
- [ ] Responsive: phone / tablet / desktop (or project bands)  
- [ ] Narrow main pane / split IDE (if app shell) — no huge empty gutters / clipped CTAs  
- [ ] Visually distinctive vs generic AI defaults  

### Pass 2 — UX, interaction & accessibility

- [ ] Primary journey completable  
- [ ] Nav orientation clear  
- [ ] Loading / empty / error / success present where async  
- [ ] Keyboard path + visible focus  
- [ ] Labels / semantics / icon-only names  
- [ ] Touch targets on touch bands  
- [ ] Contrast AA target for text/UI  
- [ ] `prefers-reduced-motion` respected  
- [ ] No hover-only critical actions  

**Target:** WCAG 2.2 AA as design goal (not a legal certification claim).

### Pass 3 — Performance & polish

- [ ] No obvious interaction jank on critical path  
- [ ] Animation cost acceptable; reduced-motion path works  
- [ ] No large unexplained layout shifts  
- [ ] Bundle/deps justified if new  
- [ ] Regression vs prior screen (if redesign)  
- [ ] Core Web Vitals: interpret lab vs field; no fake precision  

## Verdicts

| Verdict | Meaning |
|---------|---------|
| **PASS** | Critical checks evidenced OK |
| **PARTIAL** | Works; non-blocking UX/style gaps listed |
| **FAIL** | Broken flow, a11y blocker, or unchecked critical AC |
| **SKIPPED** | Tool missing — gaps listed; do not invent PASS |

Fix FAIL; re-run affected passes. Scale effort: one-line CSS tweak ≠ full Playwright suite.

## Report sketch (chat)

```markdown
## UI/UX Craft — verification
- Spec: <one-liner>
- References used: <urls>
- Pass 1/2/3: PASS|PARTIAL|FAIL|SKIPPED
- Evidence: <paths or UNVERIFIED>
- Licenses: <notes>
- Open gaps: …
```
