# Motion design engine

**Principle:** Motion improves orientation, feedback, meaning, and perceived quality. Volume of animation is not a quality metric.

## Categories

| Category | Job |
|----------|-----|
| Microinteractions | Confirm control engagement (press, toggle, like) |
| State transitions | Make mode changes readable (edit↔view, expand) |
| Enter / exit | Mount/unmount without spatial jump |
| Loading / progress | Time feels accounted for |
| Page transitions | Continuity between routes |
| Scroll-triggered | Reveal hierarchy along reading path |
| Gesture-driven | Map to platform gestures; provide alternatives |
| Drag & drop | Spatial affordance + drop feedback + cancel |
| Spatial / 3D | Only when it clarifies structure or brand signature |
| Ambient | Atmosphere — never blocks content or burns CPU forever |

## Spec template (non-trivial motion)

For each important animation, define:

1. **Purpose** (one sentence)  
2. **Trigger**  
3. **From → to**  
4. **Duration** (ms) or spring (`stiffness`/`damping`)  
5. **Easing**  
6. **User feedback** delivered  
7. **`prefers-reduced-motion`** behavior (instant cut, opacity-only, or static)  
8. **Perf notes** (main-thread risk, GPU layers, will-change sparingly)  

## Technical rules

- Prefer **transform** and **opacity**; avoid animating layout properties when possible.  
- Avoid layout thrashing and render storms (`useState` on pointer move → prefer motion values / CSS).  
- Add animation libraries only when CSS/`@starting-style`/View Transitions are insufficient.  
- Never block or permanently hide content behind animation.  
- No **hover-only** critical actions — provide click/tap/keyboard equivalents.  
- Preserve keyboard and screen-reader operability (focus not trapped mid-transition).  
- Honor **`prefers-reduced-motion: reduce`**.  
- No permanent WebGL/shader/particle loops without proven product value + degradation path.  
- Target smooth interaction; do **not** claim specific FPS without measurement.  

## Stack hints (optional — detect first)

| Stack signal | Prefer |
|--------------|--------|
| `motion` / `framer-motion` present | Reuse; isolate client islands |
| CSS-only project | `@keyframes`, transitions, scroll-driven if supported |
| React Native | Reanimated / Moti if already in project |
| Flutter | Implicit/explicit animations / Hero |
| None | CSS first; do not add Motion casually |

## Anti-patterns

- Every card auto-shimmers  
- Staggered hero of 12 elements with no hierarchy reason  
- Scroll hijack that breaks browser find / a11y  
- Marketing marquee spam (max one intentional marquee per marketing page)  
