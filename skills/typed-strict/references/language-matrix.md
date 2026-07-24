# Loose-typing language matrix

Run **only on changed paths**. Adjust globs to the project layout. Prefer project `AGENTS.md` / `.qa/project.yaml` overrides when present.

## typescript / javascript

**Extensions:** `.ts`, `.tsx`, `.mts`, `.cts`, `.js`, `.jsx` (JS only if project uses JSDoc/checkJs or forbids `any` in AGENTS)

```bash
rg ': any\b|as any\b|<any>|Array<any>|Promise<any>|Record<string,\s*any>' <CHANGED> -g '*.{ts,tsx,mts,cts}'
rg '@ts-ignore|@ts-nocheck|@ts-expect-error' <CHANGED> -g '*.{ts,tsx,js,jsx}'
rg 'eslint-disable.*no-explicit-any|eslint-disable-next-line.*no-explicit-any' <CHANGED>
```

**Replace with:** concrete types, generics, Zod inference, `unknown` + narrowing, `Record<string, unknown>`.

## python

```bash
rg '\bAny\b' <CHANGED> -g '*.py'
rg 'type:\s*ignore|pyright:\s*ignore|mypy:\s*ignore|noqa:.*type' <CHANGED> -g '*.py'
rg 'cast\(' <CHANGED> -g '*.py'   # review; not always ban — flag unexplained casts
```

**Replace with:** concrete types, `TypeVar`, Pydantic models, `object` + `isinstance` narrowing. Prefer fixing over `# type: ignore`.

## go

```bash
rg '\binterface\{\}' <CHANGED> -g '*.go'   # review empty interface abuse in public APIs
rg '//nolint' <CHANGED> -g '*.go'
```

**Replace with:** concrete types or small interfaces; avoid `any`/`interface{}` in exported APIs without justification.

## rust

```bash
rg '\bas_any\b|Any\b' <CHANGED> -g '*.rs'
rg '#\[allow\(.*\)\]' <CHANGED> -g '*.rs'  # review; ban allow(clippy::*) used to hide typing debt if AGENTS says so
```

## php

```bash
rg '@var\s+mixed\b|\bmixed\b' <CHANGED> -g '*.php'
rg '@phpstan-ignore|@psalm-suppress' <CHANGED> -g '*.php'
```

## ruby

```bash
rg '#\s*rubocop:disable.*Style/.*|T\.untyped|untyped' <CHANGED> -g '*.rb'
```

## java / kotlin

```bash
rg '\bObject\b|\bAny\??' <CHANGED> -g '*.{java,kt,kts}'   # context-sensitive; prefer flagging raw types / unchecked
rg '@SuppressWarnings\(\s*"unchecked"|"rawtypes"' <CHANGED> -g '*.{java,kt,kts}'
```

## csharp

```bash
rg '\bdynamic\b|#pragma\s+warning\s+disable' <CHANGED> -g '*.cs'
```

## shell / yaml / sql

No classic `any`. Still forbid **secret** and **unvalidated** interpolations via project security gates — not this matrix.

## Severity defaults

| Match | Default |
|-------|---------|
| Explicit escape (`any`, `Any`, `@ts-ignore`, `type: ignore`, `eslint-disable no-explicit-any`) | **BLOCK** on touched files |
| Contextual (`interface{}`, `cast(`, `mixed`) | **WARN** unless AGENTS.md makes them ZERO TOLERANCE |

When `AGENTS.md` lists `any` as Non-Negotiable (e.g. Browo HR), treat TypeScript row as **BLOCK** always on touched paths.
