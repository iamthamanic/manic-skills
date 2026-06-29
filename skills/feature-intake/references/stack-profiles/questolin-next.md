# Stack profile: questolin-next

Read with `AGENTS.md` and `.cursor/rules/questolin.mdc`.

## Runtime

| Axis | Value |
|------|-------|
| Frontend | Next.js 14 App Router |
| Styling | Tailwind + DaisyUI |
| Content | JSON + Zod (`content/`, `lib/content/`) |
| Deploy | Vercel |

## Code paths

| Concern | Prefer |
|---------|--------|
| Content | `content/topics/de/*.json`, `npm run validate:content` |
| Slides | `components/slides/`, `lib/slides/registry.ts` |
| No React in | `lib/content/` |

## Checks

```bash
npm run checks
```

## Helper

Label `content` or paths `content/topics/` → `@questolin-content-layer` (project-local).

## Dev

`npm run dev` → http://localhost:3000
