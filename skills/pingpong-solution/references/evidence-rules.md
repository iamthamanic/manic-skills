# Evidence Rules

Every factual claim must be sourced. No "best practice" without backing.

## Claim types

| Type | Required source | Example citation |
|------|-----------------|------------------|
| Codebase pattern | Read file + path | `GameCard.tsx` uses element gradients |
| Project rule | AGENTS.md / .mdc | No React in `src/game/` |
| Library API | Context7 MCP or official docs | Playwright webServer config |
| Industry / SOTA | Web search with year | "CSS animations + prefers-reduced-motion (2024)" |
| User intent | User message in chat | "User wants live burst, not trailer" |

## Verification steps

1. **Codebase claims** — grep/read before stating "already exists" or "does not exist"
2. **Library claims** — Context7 or official docs; note version if relevant
3. **SOTA claims** — prefer recent sources; say when uncertain
4. **Unknown** — state "unverified" and cap confidence

## Forbidden

- "Everyone uses X" without source
- "99% confidence" without rubric
- Recommending stack forbidden by AGENTS.md (e.g. Next.js in Letz Fetz)

## Tools

- Codebase: Read, Grep, SemanticSearch
- Docs: Context7 MCP (`resolve-library-id` → `query-docs`)
- Current practices: WebSearch (when docs silent)
