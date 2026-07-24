# {{PROJECT_NAME}}

<!-- One-line tagline -->

Short description of the project. See [docs/PRD.md](docs/PRD.md) for product scope.

## Prerequisites

- Node.js {{NODE_VERSION}}+ (recommended)
- npm or pnpm
- <!-- other tools: Docker, Supabase CLI, etc. -->

## Setup

```bash
# From repository root
cd {{APP_ROOT}}
npm install
cp .env.example .env   # if present — fill values locally, never commit secrets
```

## Development

```bash
cd {{APP_ROOT}}
npm run dev
```

Open [{{DEV_URL}}]({{DEV_URL}})

## Checks (quality gate)

```bash
npm run checks
```

Runs lint, typecheck, build, and/or tests — see [AGENTS.md](AGENTS.md) for project-specific commands.

## Tests

```bash
npm test              # unit tests, if configured
npm run test:e2e      # Playwright — bootstrap via @verify-ui skill
```

## Project structure

```
{{WORKSPACE}}/
├── {{APP_ROOT}}/     # application source
├── docs/
│   ├── PRD.md
│   └── UI_STYLEGUIDE.md
├── .qa/              # design, acceptance, verify-ui config
└── AGENTS.md         # agent instructions
```

## Environment variables

Document variables in `.env.example`. Do not commit real secrets.

| Variable | Purpose |
|----------|---------|
| | |

## Agent workflow

For AI-assisted development:

1. `@project-setup` — bootstrap (once)
2. `@pingpong-solution` — design before features
3. `@implement` — code + acceptance artifact
4. `@verify-ui` — browser verification

See [AGENTS.md](AGENTS.md).

## License

<!-- TBD -->
