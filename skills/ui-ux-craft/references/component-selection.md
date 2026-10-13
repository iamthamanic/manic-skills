# Component selection, dependencies & licenses

## Decision order

1. **Local design system / existing components**  
2. **Registry copy into repo** (shadcn-style) that matches stack  
3. **Small, well-licensed library** already aligned with deps  
4. **Hand-roll** only when simpler than adapting a mismatched component  

Use `@ponytail` / `@search-first` when available: laziest solution that works.

## License policy

Open source preferred. Copyleft is allowed **if compatible** with the project — never assume MIT.

Before adopting a component:

| Check | Action |
|-------|--------|
| Exact license of **this** component | Read LICENSE / component page |
| Extra terms (Commons Clause, Aceternity “no redistribute as library”) | Honor |
| Commercial use | Confirm allowed |
| Project license compatibility | MIT/Apache/BSD ≠ GPL/AGPL |
| Redistribution / SaaS / self-host obligations | Document |
| Attribution / NOTICE | Keep required notices |
| Transitive deps | Size, maintenance, security |
| Unclear / incompatible | **Do not use** — find alternative or build minimal |

### Known patterns (verify again before ship)

| Source | Typical stance (re-check) |
|--------|---------------------------|
| shadcn/ui, Kokonut UI | MIT — own copied code |
| Magic UI / Cult UI (many pkgs) | Often MIT — confirm package |
| React Bits | MIT + **Commons Clause** — product OK; no resell as component pack |
| Aceternity UI | Commercial products OK; **no** competing redistribution |
| 21st.dev / Uiverse | **Per author / per component** |
| Hover / Fancy / UI Layouts | Verify per asset |

Do **not** copy proprietary/marketing site designs pixel-for-pixel as if licensed.

## Dependency hygiene

- Prefer copy-into-repo over new runtime vendor lock-in when that is the project’s model.  
- Do not add Motion/Three/GSAP “just in case”.  
- Match existing animation stack.  
- Record new deps + license in the chat verification note.  

## Inspiration vs identity

References improve craft. The product must still look like **this** brand — not a 21st.dev demo farm or an Aceternity clone.
