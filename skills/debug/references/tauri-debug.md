# Tauri vs web — debug profiles

## Detection

| Signal | Profile |
|--------|---------|
| `src-tauri/tauri.conf.json` exists | `tauri` |
| `package.json` scripts `dev:desktop`, `tauri dev` | `tauri` |
| Only `vite` / `next dev` | `web` |
| No `index.html` / no frontend `main` | `api-only` |

Read `.qa/project.yaml` when present:

```yaml
devCommand: npm run dev:desktop
devUrl: http://localhost:3000
```

## Three layers in Tauri apps

| Layer | What breaks | How to observe |
|-------|-------------|----------------|
| **Web (React/Vite)** | UI, routing, React Query | Playwright @ `devUrl`, browser MCP |
| **Tauri bridge** | `invoke`, permissions, dialogs | Often **not** in Playwright-only repro |
| **Rust** | FS, crashes, native APIs | Terminal from `tauri dev`, `RUST_LOG=debug` |

## Repro strategy

### A) UI-only bug

1. Start `devCommand` (usually `npm run dev:desktop` or project script)
2. Playwright against `devUrl` **or** browser MCP navigate to `devUrl`
3. **Repro grade:** `partial (vite-only)` if app works same in Vite-only mode; else note Tauri window required

### B) `invoke` / FS / workspace scope bug

1. Run full desktop: `npm run dev:desktop`
2. Playwright may **not** reproduce — flag `tauri-native-layer`
3. Collect:
   - Terminal stderr/stdout from Tauri process
   - User WebView console (Tauri dev: context menu → Inspect Element where enabled)
   - Code: `src-tauri/src/commands/`, capabilities in `tauri.conf.json`
4. **Repro grade:** `full` only if native path verified; else `partial` + explicit gap

### C) Rust panic

```bash
RUST_LOG=debug npm run dev:desktop
```

Reproduce once; capture backtrace lines from terminal.

## Playwright webServer for Tauri projects

```ts
webServer: {
  command: process.env.TAURI_DEBUG_VITE_ONLY ? 'npm run dev:vite' : 'npm run dev:desktop',
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
  timeout: 120_000,
},
```

Use `TAURI_DEBUG_VITE_ONLY=1` when isolating React layer.

## Report requirements

Always state **repro grade** in debug report:

- `full` — bug seen in target environment
- `partial (vite-only)` — only reproduced without Tauri native APIs
- `not-reproduced` — steps could not trigger issue

Never claim Tauri FS/invoke bugs fixed based only on Vite browser tests.
