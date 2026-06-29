# UI Styleguide — {{PROJECT_NAME}}

<!-- Style tree: tokens → components → patterns. Scaffolded by /project-setup -->

Reference for humans and agents. `@verify-ui` uses this for visual/UX sanity checks.

## Principles

- Consistent spacing and typography
- Every interactive UI: default, hover, focus, disabled, loading, error
- UI copy language: **{{LOCALE_UI}}**

## Design tokens

Define in CSS/Tailwind config — no hardcoded magic numbers in components without token.

| Token | Value | Usage |
|-------|-------|-------|
| `--color-primary` | | Primary actions |
| `--color-surface` | | Backgrounds |
| `--radius-md` | | Cards, inputs |
| `--space-4` | | Default gap |

## Typography

| Role | Font | Size | Weight |
|------|------|------|--------|
| Heading | | | |
| Body | | | |
| Label | | | |

## Components

Document project primitives (not every third-party widget).

| Component | Location | Notes |
|-----------|----------|-------|
| Button | `src/components/ui/Button` | variants: primary, ghost, danger |
| Input | | |
| Modal | | |

## Layout

- Max content width:
- Breakpoints: mobile {{MOBILE_WIDTH}}px, desktop {{DESKTOP_WIDTH}}px

## States (required)

| State | Pattern |
|-------|---------|
| Loading | skeleton or spinner + aria-busy |
| Empty | illustration/icon + short copy + CTA |
| Error | message + retry when applicable |
| Disabled | reduced opacity + no pointer events |

## Accessibility

- Focus visible on all interactive elements
- Form fields: associated labels
- Color contrast WCAG AA minimum

## Do / Don't

**Do**

- Reuse tokens and existing primitives
- Match patterns from sign-in / primary forms elsewhere in app

**Don't**

- Introduce one-off colors outside tokens
- Ship features without empty/error states
