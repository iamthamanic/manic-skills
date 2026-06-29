# Stack profile: Monorepo

Apply when root `package.json` has `workspaces` or multiple app `package.json` files.

## Discovery priority

1. `.qa/setup-profile.yaml` → `appRoot` (strongly recommended)
2. README / AGENTS explicit mention
3. Folder with primary `dev` script + frontend framework
4. Avoid workspace root if it only orchestrates (`npm run dev --prefix X`)

## .qa/project.yaml

Always set explicit `appRoot`:

```yaml
appRoot: packages/web   # example
devCommand: npm run dev --prefix packages/web
# OR run from app root — document in README
```

## Paths

| Artifact | Location |
|----------|----------|
| PRD, AGENTS, .qa/ | Usually **workspace root** (product level) |
| Styleguide | Often `<appRoot>/docs/UI_STYLEGUIDE.md` |
| shimwrappercheck | Workspace root OR app root — match where `run-checks.sh` lives |

## shimwrappercheck

- One shim config per repo root is typical
- Document which package owns checks in AGENTS.md
- Fallow/stubtree: run against **app root**, not monorepo root

## README

Document:

```bash
npm install          # root
npm run dev -w web   # or --prefix path
```

## Common pitfall

Tools run at wrong root → false dead-code / unresolved imports. Always print app root in setup report.
