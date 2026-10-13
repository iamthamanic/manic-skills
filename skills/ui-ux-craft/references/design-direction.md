# Design direction

Use with `@frontend-design` (general UI) and `@design-taste-frontend` (landing/portfolio) when those skills exist. This file is the fallback + orchestrator checklist.

## Output of Phase C

A short, project-specific language — not a generic “modern SaaS” kit:

1. **Subject & audience** — one sentence  
2. **Signature** — one memorable idea (type treatment, layout device, motion motif, material)  
3. **Type** — display + body (+ mono if data); weights/scale; no default Inter-unless-brief  
4. **Color** — 4–6 named tokens; semantic roles (primary, danger, muted, surface); one accent lock  
5. **Space & grid** — base unit, density band (gallery ↔ cockpit)  
6. **Surface** — radius scale, border, elevation (or flat); consistent shape system  
7. **States** — hover/focus/active/disabled/invalid/loading for primary controls  
8. **Motion language** — one sentence (e.g. “snappy springs on feedback; calm fades on navigation”)  
9. **Responsive strategy** — recompose vs shrink; touch targets  

## Anti-defaults (AI tells)

Do not ship without justification:

- Purple/indigo mesh heroes, neon outer glows, infinite card shimmer  
- Warm cream + terracotta + display serif as unexamined default  
- Broadsheet hairlines + zero radius as unexamined default  
- Three equal feature cards, div-fake screenshots, scroll-cue clutter  
- Em-dash decoration as design flourish  
- Motion that does not communicate hierarchy, feedback, storytelling, or state change  

## Consistency locks

- One accent family across the surface  
- One radius system (document exceptions)  
- One theme (no mid-page light/dark flip unless intentional story device)  
- CTA contrast WCAG AA; labels do not wrap awkwardly at desktop  

## Product UI vs marketing

| Surface | Bias |
|---------|------|
| Landing / marketing | Stronger signature, controlled motion, hero thesis |
| App / dashboard | Hierarchy, density, scanability; restrained motion |
| Mobile app | Platform conventions, thumb reach, safe areas |
| Hybrid | Separate “marketing chrome” from “work chrome” |

## Brand already exists

Preserve logo, primary accents, voice, and IA unless redesign is explicit. Modernize via type/spacing/motion first; full visual overhaul only when asked.
