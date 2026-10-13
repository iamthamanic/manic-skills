# Platform adaptation

Detect the app class before choosing patterns. **Never force React, Next.js, or Tailwind.**

## Application classes

| Class | Priorities |
|-------|------------|
| Marketing site / landing | Hero thesis, signature motion, conversion path |
| Web app | Design system reuse, states, forms, a11y |
| Dashboard / admin | Density, scanability, filters, tables, keyboard |
| Mobile web / PWA | Touch targets, viewport, offline/install states |
| Capacitor | Safe areas, native feel, `@mobile-performance-audit` when perf |
| React Native | Platform HIG/Material; navigators already in app |
| Flutter | Material/Cupertino consistency with existing theme |
| Native (SwiftUI/etc.) | Only if tools/access exist; follow platform HIG |

## Detection order

1. Project `AGENTS.md` / `.qa/project.yaml` / styleguide  
2. `package.json` / `pubspec.yaml` / `Podfile` / Gradle  
3. Existing UI folders and component libraries  
4. User brief  

## Hard constraints

- Prefer **existing** components and tokens over new visual systems.  
- Global token changes must remain **compatible** or be explicitly scoped.  
- Respect safe-area insets on fixed chrome.  
- Desktop split panes need narrow recomposition (or documented deviation).  
- Touch: primary controls ≥44×44; no hover-only critical paths.  

## Framework-agnostic delivery

Express design-spec in tokens and behavior; map implementation to whatever the repo already uses (CSS modules, Tailwind, styled-components, SwiftUI modifiers, Flutter ThemeData, etc.).

## Capacitor / mobile extras

- Status bar / notch / home indicator  
- Keyboard avoiding  
- Offline / sync feedback  
- Cold start perceived readiness vs fully ready (perf skills if needed)  
