# Stack → typedStrict language detection

Used by `@project-setup` (init/audit) and `@ecc-check` Phase A when `.qa/project.yaml` lacks `typedStrict.languages`.

## Algorithm (first write / merge)

1. If `typedStrict.languages` already set → keep (do not shrink silently).
2. Else run:

```bash
bash "$HOME/.claude/skills/typed-strict/scripts/detect-languages.sh" <repo-root>
```

3. Union with signals from discovery:

| Stack / signal | Add languages |
|----------------|---------------|
| `vite-react`, `next`, `cra`, monorepo with `package.json` + TS | `typescript` |
| `api-only` + Express/Fastify/Nest TS | `typescript` |
| `*.py` / `pyproject.toml` / `requirements.txt` | `python` |
| `go.mod` | `go` |
| `Cargo.toml` | `rust` |
| `composer.json` | `php` |
| `Gemfile` | `ruby` |
| `pom.xml` / `*.java` | `java` |
| `*.kt` | `kotlin` |
| `*.csproj` | `csharp` |
| Diff extensions only (ecc-check fallback) | matrix keys matching changed files |

4. Write/update `.qa/project.yaml`:

```yaml
typedStrict:
  languages: [typescript, python]  # detected set
```

5. Report in Discovery Summary / ECC Phase A: `typedStrict languages: … (auto | existing)`.

## Audit mode

- Missing `typedStrict` → **create** block with detected languages (safe additive).
- Present but incomplete vs detection → **append** missing languages; never remove without user OK.
- Document in setup report under Artifacts → `.qa/project.yaml`.

## Conflict with locale

`project.yaml` → `language: de` means **UI locale**, not programming language. Always use `typedStrict.languages` for this gate.
