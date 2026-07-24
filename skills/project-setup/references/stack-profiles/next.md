# Stack profile: Next.js

Apply when `next` in app root dependencies.

## AGENTS placeholders

| Placeholder | Value |
|-------------|-------|
| FRONTEND_STACK | Next.js (App Router or Pages — inspect `src/app/` vs `pages/`) |
| BACKEND_STACK | Route handlers / Server Actions / external API |
| STYLING | Tailwind or CSS modules — inspect project |
| TESTS | Vitest or Jest + Playwright for e2e |
| DEPLOY | Vercel |

## Default dev URL

**http://localhost:3000**

## Styleguide path

`docs/UI_STYLEGUIDE.md`

## Architecture hints

App Router:

```
src/app/
├── layout.tsx
├── page.tsx
└── api/
components/          # prefer /components at root per project convention
```

## package.json scripts

```json
"dev": "next dev",
"build": "next build",
"start": "next start",
"checks": "npm run lint && npm run build"
```

## .qa/project.yaml

- `appRoot: .` when Next app is at workspace root
- `devCommand: npm run dev`
- `typedStrict.languages: [typescript]` (+ detect-script union)

## Notes

- Respect existing `components/` folder location (root vs `src/`)
- SSR/Server Components: document in AGENTS architecture section
