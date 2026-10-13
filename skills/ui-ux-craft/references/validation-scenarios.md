# Validation scenarios (skill quality — not live project edits)

These briefings test whether an agent following `ui-ux-craft` would make the right decisions.  
**Do not modify SagaTree or Business Ultra repos when exercising these scenarios** unless the user explicitly opens that project and asks for implementation.

---

## Test A — SagaTree character sheet (TTRPG)

### Briefing

Design an interactive **character sheet** for a modern virtual tabletop: glanceable vitals, actions, inventory/skills behind progressive disclosure, fantasy/gaming character without generic AI purple mesh.

### Expected agent behavior

1. Discovery: player vs GM, session context, existing SagaTree tokens/theme (`Darker Grotesque`, cyan=primary, gold=hover).  
2. References: prefer **app** patterns (shadcn/Kokonut/21st app chrome) over landing heroes; motion from Motion Primitives/React Bits only for feedback.  
3. Chat design-spec covering IA (vitals → actions → advanced), tokens, states, reduced-motion.  
4. UX: new-player clarity + expert density; empty/error for missing character.  
5. Responsive: desktop workstation + tablet + phone recomposition (`AU-*` if contract present).  
6. Verify: keyboard + touch targets + no hover-only primary actions.  

### Acceptance criteria (for a real implementation later)

- [ ] Primary stats and HP/resources visible without hunting  
- [ ] Complex options progressively disclosed  
- [ ] Motion limited to state/feedback  
- [ ] Works in narrow main pane  
- [ ] Contrast AA; focus visible  
- [ ] Design-spec appeared in chat before code  

### Isolated skill check (no repo write)

Agent produces: chat design-spec + reference list + verification plan matching this file.  
**Status for skill authoring:** scenario documented; live SagaTree implementation **not** executed (out of scope).

---

## Test B — Business Ultra analytics dashboard

### Briefing

Modern **analytics dashboard**: sidebar, filters, data tables, multiple complex views. Professional, dense, accessible, restrained microinteractions.

### Expected agent behavior

1. Discovery: analyst workflow, filter → table → detail; existing design system.  
2. References: **shadcn** tables/sidebar/filters first; Magic/Aceternity only if marketing shell — not inside data grid.  
3. Spec: information hierarchy, filter state, empty/loading/error for queries, keyboard for tables.  
4. Motion: row hover/focus, panel expand — no ambient particles.  
5. A11y: sort headers, focus management in dialogs, contrast on muted cells.  
6. Perf: virtualize or paginate large tables; measure before heavy opts (`@test-performance-speed` if slow).  

### Acceptance criteria

- [ ] Clear hierarchy: filters → results → detail  
- [ ] Filter/query states complete  
- [ ] Table operable by keyboard  
- [ ] Microinteractions restrained  
- [ ] Dense but scannable typography/spacing  
- [ ] License notes if any registry components added  

### Isolated skill check

Agent produces: chat design-spec + component strategy favoring app primitives + QA plan.  
**Status for skill authoring:** scenario documented; live Business Ultra implementation **not** executed (out of scope).

---

## Self-check matrix (skill author)

| Criterion | Met? |
|-----------|------|
| SKILL.md + frontmatter | yes |
| Twelve sources catalogued | yes |
| Chat spec → implement without approval gate | yes |
| License fail-closed | yes |
| Stack-agnostic | yes |
| Composes existing design/verify skills | yes |
| Fallbacks if siblings missing | yes |
| Two scenarios documented | yes |
| No SagaTree/Business Ultra mutations for validation | yes |
