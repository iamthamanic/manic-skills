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

## package.json scripts to ensure

```json
"dev": "vite",
"build": "vite build",
"preview": "vite preview",
"test": "vitest",
"checks": "npm run lint && npm run build && npm test"
```

## typedStrict defaults

```yaml
typedStrict:
  languages: [typescript]
```

Run `~/.claude/skills/typed-strict/scripts/detect-languages.sh` on repo root and **union** results (e.g. add `python` if scripts exist).
