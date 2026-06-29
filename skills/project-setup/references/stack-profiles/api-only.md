# Stack profile: API-only

Apply when no frontend framework detected (Express, Fastify, Deno, pure Node library).

## AGENTS placeholders

| Placeholder | Value |
|-------------|-------|
| FRONTEND_STACK | None |
| BACKEND_STACK | Node/Express/Fastify/Deno — from package.json |
| STYLING | N/A |
| TESTS | Vitest/Jest/supertest |
| DEPLOY | Docker/Vercel serverless/Railway |

## Skip

- UI styleguide (Step 6)
- `navigation` in project.yaml (empty array)
- Playwright in README unless user plans a frontend later

## .qa/project.yaml

```yaml
appRoot: .
checksCommand: npm run checks
# omit devUrl or set to API health endpoint if documented
locale: en   # unless API messages are localized
navigation: []
```

## shimwrappercheck preset

- Frontend checks: off or minimal (lint on `src/` if TS)
- Backend checks: on if Supabase/Deno
- Git wrapper: on

## README focus

- API endpoints overview
- How to run server locally
- `.env.example` for all secrets
- curl/httpie examples

## PRD

Often service-focused — emphasize API consumers, auth model, rate limits.
