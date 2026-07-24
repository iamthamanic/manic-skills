# MCP DevTools — console, network, exceptions

Always **GetMcpTools** and read tool schemas before `CallMcpTool`.

## Server priority

| Order | Server | Tools |
|-------|--------|-------|
| 1 | `cursor-ide-browser` | `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_cdp`, `browser_take_screenshot` |
| 2 | `user-chrome-devtools` | If connected — use native DevTools MCP tools per schema |
| — | On `needsAuth` / `error` | `mcp_auth` for that server once, retry; else browser-only |

## Interactive repro flow

```
browser_tabs (list) → browser_navigate (url from .qa/project.yaml devUrl)
→ browser_lock
→ reproduce user steps (click, fill, scroll)
→ collect evidence (CDP + screenshot)
→ browser_unlock
```

Use `browser_snapshot` before clicks — refs expire after navigation.

## CDP recipes (`browser_cdp`)

Enable domains once per tab session, then reproduce the bug.

### Console

```json
{ "method": "Log.enable", "params": {} }
```

After repro, read entries (implementation may buffer in agent turn — also use Runtime):

```json
{
  "method": "Runtime.evaluate",
  "params": {
    "expression": "(() => { const e = window.__DEBUG_LAST_ERROR__; return e ? String(e) : 'none'; })()",
    "returnByValue": true
  }
}
```

If app has no hook, rely on Log events captured during interaction and Playwright `page.on('console')` in debug spec.

### Uncaught errors (inject listener before repro)

```json
{
  "method": "Runtime.evaluate",
  "params": {
    "expression": "window.__debugErrors = window.__debugErrors || []; window.addEventListener('error', e => window.__debugErrors.push({msg: e.message, stack: e.error?.stack})); window.addEventListener('unhandledrejection', e => window.__debugErrors.push({msg: String(e.reason)})); 'ok'",
    "returnByValue": true
  }
}
```

Then after repro:

```json
{
  "method": "Runtime.evaluate",
  "params": {
    "expression": "JSON.stringify(window.__debugErrors || [])",
    "returnByValue": true
  }
}
```

### Network failures

```json
{ "method": "Network.enable", "params": {} }
```

Reproduce, then evaluate failed requests if CDP stream not visible in tool output — prefer Playwright trace HAR for full network log in e2e spec:

```ts
await page.route('**/*', () => {}); // only if needed
// use trace: 'on' in playwright.config
```

### DOM sanity at failure

```json
{ "method": "DOM.getDocument", "params": { "depth": 1 } }
```

## Playwright console capture (debug spec)

```ts
const logs: string[] = [];
page.on('console', (msg) => logs.push(`[${msg.type()}] ${msg.text()}`));
page.on('pageerror', (err) => logs.push(`[pageerror] ${err.message}\n${err.stack}`));
// ... steps ...
console.log(logs.join('\n'));
```

## Denied / avoid

- Do not use CDP `Input.*` — use `browser_click`, `browser_type`, etc.
- Cookie/storage/target-management CDP may be denied in IDE browser — use Playwright storageState if needed.
