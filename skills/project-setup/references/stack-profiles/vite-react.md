# Stack profile: Vite + React

Apply when `vite` and `react` detected in app root.

## AGENTS placeholders

| Placeholder | Value |
|-------------|-------|
| FRONTEND_STACK | Vite + React |
| BACKEND_STACK | None (local-first) or see README |
| STYLING | Tailwind CSS or CSS modules — inspect `tailwind.config.*` |
| TESTS | Vitest (add if missing) |
| DEPLOY | Static/Vercel or Tauri later |

## Default dev URL

- Read `vite.config.*` → `server.port`, default **5173**
- Custom ports common in monorepos (e.g. 4789) — prefer config over default

## Styleguide path

`docs/UI_STYLEGUIDE.md` or `<appRoot>/docs/UI_STYLEGUIDE.md`

## Architecture hints

```
src/
├── components/
│   └── ui/          # shared primitives
├── pages/ or routes/
├── hooks/
├── services/
└── main.tsx
```

## shimwrappercheck preset

- Frontend checks: ESLint, TypeScript, Vitest, Vite build
- Supabase: off unless `supabase/` exists
- Git wrapper: on if `.git`

## package.json scripts to ensure

```json
"dev": "vite",
"build": "vite build",
"preview": "vite preview",
"test": "vitest"
```

## Fallow notes

- Run from **app root** after `npm install`
- Ignore `src/components/ui/*` if shadcn-style unused components kept intentionally
