---
name: conversation-to-prd
description: >-
  Convert a conversation, discovery transcript, product notes, attachments, or repository context into a source-traceable, implementation-ready software Product Requirements Document (PRD). Use when asked to write, derive, consolidate, audit, or update a PRD, product specification, technical product brief, MVP specification, Pflichtenheft, Lastenheft, or "Gespräch in PRD", especially when an AI coding agent will implement the result. Cover product context, problem and solution, scope, users, journeys, scenarios, edge cases, UX/style guide, architecture, tech stack, repository structure, data and API contracts, security, accessibility, quality attributes, analytics, testing, delivery, decisions, assumptions, risks, and traceability. Do not use for implementation-only requests, a standalone business plan, or a short feature summary that is not intended to guide implementation.
---
# Conversation to PRD

Create a PRD that another capable agent can implement without silently inventing product behavior. Optimize for correctness, traceability, testability, and explicit uncertainty rather than document length.

## Load the working references

1. Read [references/extraction-and-traceability.md](references/extraction-and-traceability.md) before extracting source material.
2. Read [references/prd-template.md](references/prd-template.md) before drafting. Preserve its `prd-section` HTML comments so the validator remains language-independent.
3. Read [references/quality-gates.md](references/quality-gates.md) before final validation.

## Choose the operating mode

- **Default — one-pass:** Derive the best complete PRD from available material. Record non-blocking gaps under assumptions and open decisions. Do not interrupt drafting merely to improve completeness.
- **Interactive discovery:** Use only when the user requests an interview, workshop, iterative refinement, or question-led process. Ask at most five high-impact questions per round, ordered by implementation risk.
- **Update:** Preserve stable IDs and accepted decisions from an existing PRD. Add a change log and mark superseded decisions; do not silently rewrite history.
- **Audit:** Do not rewrite unless requested. Report missing, contradictory, unverifiable, or implementation-blocking material against the quality gates.

## Workflow

### 1. Establish the evidence boundary

- Treat the visible conversation, user-provided files, explicitly referenced sources, and inspected repository as evidence.
- Inspect an available repository before asserting its current stack, architecture, commands, conventions, or folder layout.
- Browse only when the user asks for research, a referenced external source must be read, or current external facts materially affect the specification. Prefer primary sources.
- Never treat model memory or a conventional default as user-confirmed fact.

### 2. Build the source and claim ledger

- Assign source IDs `S-001`, `S-002`, and so on.
- Classify material claims with exactly one canonical status:
  - `[CONFIRMED]` — directly supported by evidence.
  - `[INFERRED]` — strongly implied; include the inference basis.
  - `[PROPOSED]` — a recommended default; include rationale and alternatives.
  - `[UNKNOWN]` — missing and not safe to infer.
  - `[CONFLICT]` — incompatible statements exist; retain both sources.
- Keep quoted conversation text short. Prefer faithful paraphrase plus source ID.
- Keep product requirements separate from technical proposals. A proposed framework is not a product requirement.

### 3. Resolve only genuine blockers

Pause before drafting only when an unanswered choice could make the document unsafe or fundamentally incoherent, such as destructive data behavior, regulated data handling, financial transfers, authorization boundaries, tenancy isolation, or mutually exclusive core product definitions.

Otherwise continue with visible assumptions. Never hide uncertainty behind polished prose.

### 4. Define intent and boundaries

- Draft in two passes. First establish the user-value spine `problem -> actor -> journey -> FR -> SCN`; then add only the applicable UX, data, architecture, quality, and delivery detail around that spine.
- State the context, evidence-backed problem, affected users, current alternative, proposed solution, desired outcomes, success metrics, constraints, dependencies, non-goals, MVP boundary, and later scope.
- Distinguish output metrics from outcome metrics.
- Do not invent market evidence, deadlines, budgets, traffic, compliance obligations, or numerical targets. Mark proposed targets `[PROPOSED]`.
- Write a small product constitution: durable principles and constraints that implementation choices must obey.

### 5. Specify behavior before structure

- Map actors, roles, jobs, permissions, end-to-end journeys, system states, happy paths, alternate paths, failure recovery, admin/support flows, and destructive actions.
- Give every functional requirement an `FR-###` ID and every scenario an `SCN-###` ID.
- Use Given/When/Then for acceptance scenarios. Cover successful, negative, boundary, permission, retry, and recovery behavior where applicable.
- Record cross-cutting edge cases with `EDGE-###` IDs. Do not use a generic edge-case dump as a substitute for feature-specific behavior.

### 6. Specify the implementation contract

- Describe information architecture, screens/routes, responsive behavior, content rules, component states, and design tokens. Convert style adjectives into observable visual rules or mark them as references needing assets.
- Define entities, fields, relationships, ownership, invariants, state transitions, retention, deletion, and migration implications.
- Define authorization separately from authentication. Include role/permission matrices and tenant boundaries where relevant.
- Describe system context, deployable containers, component responsibilities, data flows, integrations, trust boundaries, failure handling, idempotency, retries, timeouts, concurrency, caching, configuration, and secrets.
- State tech stack and repository structure only as confirmed constraints or labeled proposals. Include file/module ownership and dependency direction, not decorative folder trees.
- Define API/event contracts when relevant: operation, auth, input, output, validation, errors, pagination, idempotency, versioning, and compatibility.
- Record architecturally significant choices as `D-###` decisions with status, context, choice, alternatives, and consequences.

### 7. Make quality measurable

- Assign `NFR-###` IDs to quality requirements.
- Replace terms such as fast, secure, scalable, intuitive, robust, and accessible with measurable thresholds or explicit verification methods.
- Cover only applicable dimensions, but always evaluate performance, reliability, availability, durability, security, privacy, accessibility, compatibility, maintainability, observability, localization, cost, and capacity.
- Mark missing targets `[UNKNOWN]` or recommended targets `[PROPOSED]`; never create false precision.

### 8. Make delivery verifiable

- Define analytics events and properties, operational logs/metrics/traces, alert conditions, data minimization, and prohibited sensitive fields.
- Map test levels to requirements: unit, integration, contract, end-to-end, visual, accessibility, security, performance, and recovery as applicable.
- Include migration, rollout, feature flags, backward compatibility, rollback, runbooks, and support ownership when applicable.
- Sequence delivery as vertical user-value slices. Do not disguise a speculative task estimate as fact.

### 9. Complete traceability and readiness

- Map each goal to requirements, scenarios, components/contracts, tests, and metrics.
- Ensure every `FR-###` and `NFR-###` appears in the traceability matrix.
- Maintain assumption IDs `A-###`, question IDs `Q-###`, risk IDs `RISK-###`, and decision IDs `D-###`.
- Assign exactly one final status:
  - `READY FOR IMPLEMENTATION`
  - `READY WITH ASSUMPTIONS`
  - `BLOCKED`
- A document is `BLOCKED` when unresolved items affect safety, legal compliance, irreversible data behavior, core authorization, tenancy isolation, money movement, or mutually exclusive core scope.

### 10. Validate and deliver

1. Save a single Markdown PRD unless the user requests another format or an existing project convention requires multiple files.
2. Run `python3 scripts/validate_prd.py <path-to-prd>` from this skill directory.
3. Fix validation errors. Review warnings; retain one only with an explicit reason in the PRD.
4. Check the document manually against [references/quality-gates.md](references/quality-gates.md).
5. Deliver the PRD plus a concise summary of readiness, blocking decisions, and proposed defaults. Do not claim implementation-ready status when the gates fail.

## Writing rules

- Match the user's language. Keep canonical IDs, status tags, and HTML section markers unchanged.
- Use precise, atomic statements. One requirement should express one independently testable obligation.
- Use tables for exact mappings and matrices. Use Mermaid only when topology, state, or event order is materially clearer than prose.
- State rationale and trade-offs without exposing private chain-of-thought.
- Write `Not applicable — <reason>` for a deliberately excluded template section. Never delete a mandatory section silently.
- Keep a non-applicable section to that one reason line. Do not reproduce empty template tables or generic boilerplate.
- Avoid duplicating the same rule across sections; reference its stable ID instead.
- Never embed credentials, private keys, tokens, or unnecessary personal data.
