# UX engineering

If `@ux-design-laws` is installed, apply it for task-completion laws. This file remains the orchestrator checklist and fallback.

## Always ask

- What is the user’s **one primary goal** on this screen?  
- What is the **shortest clear path**?  
- What is the **obvious next action**?  
- What happens on **empty / loading / error / success / offline / permission denied**?  

## Mandatory review (when relevant)

| Area | Pass criteria |
|------|----------------|
| Information hierarchy | Primary content first; secondary de-emphasized |
| Navigation / orientation | User knows where they are and how to leave |
| Discoverability / affordances | Controls look actionable; icons have names |
| Progressive disclosure | Advanced options behind clear reveal — not hidden forever |
| Cognitive load | Chunked; defaults sensible; no parallel competing CTAs of same intent |
| Feedback / system status | Action acknowledgment &lt; ~400ms perceived; progress when slow |
| Error prevention | Impossible actions disabled; destructive confirmed |
| Undo / recovery | Work preserved; clear fix path |
| Keyboard | Logical tab order; visible focus; no keyboard traps |
| Touch | Primary targets ≥44×44 CSS px on touch bands |
| Gestures | Platform-conventional; not the only path for critical actions |
| Responsiveness | Recompose for narrow panes / phone — not only shrink |
| Microcopy | Plain verbs; consistent action names; errors instruct |
| Consistency | Same action → same pattern across screens |

## Dual audience

Design so beginners succeed without tutorial walls, and experts get density/shortcuts (keyboard, bulk actions, remembered filters) without removing power features.

## Adaptive / content width

When the project has Adaptive UI contracts (`AU-*` / `docs/concepts/adaptive-ui-experience-contract.md`):

- Classify surface: Journey / Workstation / Live / Overlay  
- Prefer container/content-width awareness over viewport-only breakpoints for Journey columns  
- Workstation panes: `min-w-0` / overflow containment  

If no contract exists, still avoid horizontal page scroll and hover-only critical actions.

## Do not

- Restyle a broken flow without fixing IA  
- Add decorative widgets that compete with the primary task  
- Rely on color alone for state  
- Ship hover-only menus as the sole path to critical actions  
