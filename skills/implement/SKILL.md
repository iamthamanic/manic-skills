---
name: implement
description: >-
  Enforces implementation contract: reads .qa/design from pingpong-solution,
  auto-generates .qa/acceptance before code, minimal diffs, Ponytail lazy-senior-dev
  ladder, security, validation. Use for features, bug fixes, refactors, or code
  changes after /pingpong-solution.
---

# Implementation Contract

When implementing changes, follow this contract strictly.

## Pipeline position

```
@pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket
```

## Global helper skills (ECC, `~/.cursor/skills/`)

Apply **inline** — follow their checklists while executing this contract.

| Helper | Trigger in implement |
|--------|----------------------|
| `@foundations` | **§0–3** — new module/adapter, unclear boundaries, refactor; Pre/Post in acceptance (Hoare); module split (Parnas) |
| `@search-first` | **§2** — before new utils, deps, or abstractions; reuse repo patterns first |
| `@documentation-lookup` | New library/API/MCP integration — read current docs before coding |
| `@security-review` | **§5** — auth, UGC, storage, P2P, secrets, user input, Card Forge content |
| `@strategic-compact` | Large diff / long session — compact after acceptance written, before bulk coding |

After **§11**: always **`@verify-ticket`**; if UI changed, recommend **`@verify-ui`** before review. Pre-PR full gate: **`@verification-loop`** (uses AGENTS.md checks command).

## 0. Acceptance artifact (mandatory, before code)

**Before any code changes**, auto-generate the acceptance contract for this feature.

Read [references/acceptance-artifact.md](references/acceptance-artifact.md) and:

1. Derive `feature-slug` (kebab-case)
2. Ensure `.qa/acceptance/` exists (and `.qa/project.yaml` if missing — see verify-ui template)
3. Read `.qa/design/product-roadmap.md` for sprint priority, stufe, and exit criteria
4. If `.qa/design/<feature-slug>.md` exists (from `@pingpong-solution`), use it as **primary input** for Intent, Happy Path, Edge Cases, and scope
5. Write or update `.qa/acceptance/<feature-slug>.md` from roadmap + design artifact + chat + `.qa/edge-cases.md` + `AGENTS.md` + styleguide — use **Preconditions** + postcondition-style Happy Path per `@foundations` (Hoare)
6. List the file path in your first progress message so the user can skim Intent/Happy Path

The user **must not** manually copy acceptance templates. This step replaces that.

If no design artifact exists, suggest `@pingpong-solution` when the request was exploratory — but still generate acceptance from chat if user proceeds with `/implement`.

After coding, fill the **Implementation Notes** section only — do not mark checkboxes (verify-ui does that).

Skip only for pure refactors / typo / docs-only — document skip reason in final report.

## 1. Read and respect project rules first

Before changing code, read and follow all relevant project instructions, including:

* AGENTS.md
* `.qa/design/architecture-freeze.md` when present — **do not add feature code to frozen paths**; extract first
* README.md
* package/config files
* framework conventions
* existing architecture patterns
* existing UI/UX patterns
* existing testing and validation setup

If instructions conflict, stop and explain the conflict before implementing.

## 2. Understand the existing structure before editing

Before implementation:

* identify the relevant files and modules
* understand existing data flow
* understand existing component/service boundaries
* reuse existing utilities, components, types, schemas, hooks, services, and patterns
* avoid creating duplicate abstractions
* avoid broad refactors unless explicitly required

Do not implement by guessing. Inspect the codebase first.

**Foundations (Parnas):** Before a new file or layer, name the **one design decision** it hides. Prefer extending an existing module boundary over a parallel util. If boundaries are unclear, read `@foundations` before coding.

## 3. Keep the implementation minimal and architecture-aligned

Implement the requested feature with the smallest clean change that fits the existing architecture.

Follow:

* separation of concerns
* single responsibility
* DRY where it actually reduces duplication
* SOLID where applicable
* explicit data flow
* clear naming
* low coupling
* high cohesion
* no unnecessary abstractions
* no unrelated changes
* no formatting churn in unrelated files

Do not introduce new dependencies unless they are clearly justified.

### Ponytail (primary — during `@implement`)

Apply the [Ponytail](https://github.com/DietrichGebert/ponytail) lazy-senior-dev ladder **before writing code**. Attach `@ponytail` (installed at `~/.cursor/skills/ponytail/`).

**Ladder — stop at the first rung that holds:**

1. Does this need to exist? (YAGNI — skip speculative work)
2. Stdlib / built-in language feature?
3. Native platform or existing UI primitive? (e.g. DaisyUI before custom component)
4. Already-installed dependency?
5. One line?
6. Only then: minimum new code that works

**Conflict rule:** `AGENTS.md`, PRD, and design artifact **win** over Ponytail. Never use Ponytail to bypass architecture layers, security, tests, or accessibility.

**Still required:** validation at trust boundaries, error handling that prevents data loss, security, accessibility basics, tests when behavior changes (§7). Mark intentional shortcuts with `// ponytail:` and name the ceiling + upgrade path.

**After large diffs:** suggest `@ponytail-review` (installed at `~/.cursor/skills/ponytail-review/`) before claiming done.

## 4. Ask only for blocking uncertainty

Do not ask questions for things that can be safely inferred from the existing codebase.

Ask before continuing only when there is a real blocker, such as:

* destructive database changes
* ambiguous product behavior
* security-sensitive tradeoffs
* missing required credentials or environment variables
* unclear authorization rules
* breaking API changes
* paid external services
* irreversible migrations
* changes that conflict with existing project rules

If uncertainty is minor, choose the safest conventional option and document the assumption.

## 5. Security requirements

All implementation must be secure by default.

Check and handle:

* input validation
* output encoding where relevant
* authentication
* authorization
* role/permission checks
* tenant/user isolation
* server-side enforcement of sensitive rules
* secrets handling
* environment variable usage
* safe logging without leaking private data
* rate limiting or abuse protection where relevant
* injection risks
* XSS risks
* CSRF risks where applicable
* SSRF risks where applicable
* unsafe file upload or path handling
* unsafe redirects
* insecure client-side trust assumptions
* privacy-sensitive data exposure

Never rely on frontend checks for security decisions. Enforce security on the server or trusted backend layer.

If a security issue is discovered while implementing, fix it if it is directly related to the change. If it is broader, stop and report it clearly.

## 6. Validation requirements

Use the validation approach that matches the current codebase.

Detect the stack and use the existing validation tools, for example:

* TypeScript type checking
* linting
* formatter checks
* unit tests
* integration tests
* end-to-end tests
* schema validation
* runtime validation
* Python type checks
* Python tests
* backend build checks
* frontend build checks
* database migration checks

Do not hardcode one validation tool unless the project already uses it.

After implementation, run `@verify-ticket` (or follow `.agents/skills/verify-ticket/SKILL.md` in this repo). If checks cannot be run, explain exactly why.

For **UI/UX changes** (components, layouts, flows, animations), also tell the user to run `@verify-ui` (skill: `~/.cursor/skills/verify-ui/`). Do not claim browser verification passed unless verify-ui was run or the user explicitly skipped it.

Never claim validation passed unless `npm run checks` actually ran successfully.

## 7. Testing requirements

Add or update tests when the change affects behavior.

Tests should cover:

* successful path
* relevant failure path
* edge cases
* permission/security behavior where relevant
* regression risk introduced by the change

Do not add shallow tests that only assert implementation details.

If the project has no test setup, do not invent a large new test framework without approval. Instead, explain the validation gap and add the smallest reasonable test only if it fits the project.

## 8. UI/UX requirements

For UI changes, follow the existing design system and product patterns.

Check:

* responsive behavior
* loading states
* empty states
* error states
* disabled states
* accessibility
* keyboard usability where relevant
* clear user feedback
* consistent spacing, typography, and component usage
* no layout shifts where avoidable
* no inconsistent copy or terminology
* no hidden broken states

Do not introduce custom UI patterns when an existing component or pattern already exists.

## 9. Data and migration requirements

For database or data model changes:

* inspect existing schema and migration style
* preserve existing data where possible
* avoid destructive changes unless explicitly approved
* include migration and rollback considerations
* update types, API contracts, seed data, and validation schemas where needed
* consider backward compatibility

Do not silently change persisted data semantics.

## 10. Documentation requirements

Update documentation when behavior, setup, API contracts, environment variables, scripts, or developer workflows change.

Documentation can include:

* README updates
* inline comments for non-obvious logic
* API docs
* environment variable documentation
* migration notes
* usage examples
* changelog entries if the project uses them

Do not add obvious comments that merely repeat the code.

## 11. Final response after implementation

After implementing, run `@verify-ticket` before claiming the ticket is done. For UI changes, run or recommend `@verify-ui` before `@review-ticket`. Then provide:

* acceptance artifact path (`.qa/acceptance/<slug>.md`) or SKIPPED reason
* concise summary of what changed
* files changed
* validation commands run (exact `npm run checks` command from verify-ticket)
* test results
* UI verification (PASS / FAIL / SKIPPED / pending — from verify-ui if run)
* Fallow result (PASS / N/A)
* AI review verdict (`VERDICT: ACCEPT` or pending)
* ticket review verdict (PASS / FAIL from verify-ticket checklist)
* known limitations
* any assumptions made
* any follow-up risks that were discovered

Be explicit about failures, skipped checks, or uncertainty.
