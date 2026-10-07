# Extraction and traceability

## Contents

1. Evidence model
2. Extraction pass
3. Contradiction handling
4. Requirement construction
5. Traceability model
6. Clarification priority

## 1. Evidence model

Treat a PRD as a controlled transformation from source evidence into implementation claims.

| Status | Meaning | Required treatment |
|---|---|---|
| `[CONFIRMED]` | Directly stated or verified in a supplied source | Add one or more `S-###` references |
| `[INFERRED]` | Strongly implied by combined evidence | State the inference basis and confidence |
| `[PROPOSED]` | Recommended default or design choice | Give rationale, alternatives, and impact if rejected |
| `[UNKNOWN]` | Material is absent or too ambiguous | Add `Q-###`, impact, owner if known, and latest decision point |
| `[CONFLICT]` | Sources cannot both be true | Preserve both source IDs and describe the decision needed |

Do not convert `[INFERRED]` or `[PROPOSED]` into `[CONFIRMED]` merely because the claim appears in multiple generated sections.

## 2. Extraction pass

Read the evidence twice.

### Pass A: capture facts without organizing the solution

Extract:

- actors, users, buyers, admins, support roles, and external systems;
- explicit problems, symptoms, workarounds, and evidence;
- desired outcomes and stated success measures;
- requested capabilities and prohibited behavior;
- workflows, ordering, decisions, states, and lifecycle events;
- named technologies, versions, platforms, repositories, and constraints;
- visual references, brand rules, examples, disliked patterns, and exact copy;
- data categories, permissions, integrations, compliance, and risk statements;
- deadlines, release constraints, budgets, capacity, and operating ownership;
- corrections, reversals, preferences, and unresolved disagreements.

Create a source ledger:

| Source ID | Source | Evidence summary | Reliability | Affected sections |
|---|---|---|---|---|
| S-001 | User message / file / repository path / URL | Faithful paraphrase | Direct / derived / external | IDs or section names |

For repository evidence, record exact paths and optionally commit or branch identifiers. For web evidence, record direct URLs and access date. For conversation evidence, use turn order or a short identifying paraphrase; do not invent line numbers.

### Pass B: normalize into claims

Split compound statements. Classify each claim by status. Assign it to one or more of:

- goal;
- constraint;
- functional requirement;
- quality requirement;
- design rule;
- data rule;
- security/privacy rule;
- architecture decision;
- assumption;
- risk;
- open decision;
- reference only.

Do not let a visual reference silently define functionality. Do not let a named technology silently define a user need.

## 3. Contradiction handling

Apply these rules in order:

1. A later explicit correction supersedes an earlier statement. Retain the history and cite both.
2. A user statement outranks an assistant suggestion unless the user explicitly accepts the suggestion.
3. Inspected repository state outranks an unverified claim about current implementation, but not the user's desired target state.
4. Primary external sources outrank summaries for external facts.
5. When precedence is still unclear, mark `[CONFLICT]`; do not choose the most convenient interpretation.

Use this format:

| Conflict ID | Claim A | Claim B | Sources | Impact | Decision needed |
|---|---|---|---|---|---|
| C-001 | ... | ... | S-001, S-004 | ... | Q-001 |

## 4. Requirement construction

Every requirement must be:

- atomic: one obligation;
- necessary: tied to a goal, constraint, or risk;
- unambiguous: one reasonable interpretation;
- feasible or explicitly marked as feasibility-unknown;
- testable: observable outcome or verification method;
- bounded: actor, trigger, scope, and error behavior are known;
- traceable: source and downstream test links exist;
- status-labeled: confirmed, inferred, proposed, unknown, or conflict.

Functional requirement format:

| Field | Content |
|---|---|
| ID | `FR-###` |
| Statement | The system shall `<observable behavior>` when `<trigger/condition>` for `<actor/scope>`. |
| Priority | Must / Should / Could / Won't for this release |
| Status | Canonical status tag |
| Rationale | Goal, risk, or constraint served |
| Sources | `S-###` |
| Acceptance | `SCN-###` |
| Dependencies | Requirement, data, integration, or decision IDs |

Quality requirement format:

| Field | Content |
|---|---|
| ID | `NFR-###` |
| Quality | Performance / reliability / security / etc. |
| Stimulus | Event or operating condition |
| Environment | Normal, peak, degraded, maintenance, and so on |
| Measure | Metric and collection point |
| Target | Threshold or range, including percentile and window where relevant |
| Verification | Test, inspection, analysis, or monitoring method |
| Status and source | Canonical tag plus `S-###` or rationale |

Avoid implementation wording in functional requirements unless implementation is itself a confirmed constraint. "Use PostgreSQL" is a technical decision; "preserve transactional consistency between order and payment state" is a behavioral/quality requirement.

## 5. Traceability model

Use a single matrix that links intent to verification:

| Goal | Requirement | Scenario / edge | UI / component / contract | Data | Test | Metric | Source |
|---|---|---|---|---|---|---|---|
| G-001 | FR-001, NFR-001 | SCN-001, EDGE-001 | Screen / service / endpoint / event | Entity or field | T-001 | MET-001 | S-001 |

Traceability rules:

- Every goal links to at least one requirement or is marked informational.
- Every `FR-###` links to at least one scenario and test.
- Every `NFR-###` links to a verification method and metric where measurement is possible.
- Every screen, endpoint, event, and persisted entity links to a requirement.
- Every analytics event links to a decision it supports; remove vanity events.
- Every risk links to a mitigation, contingency, accepted-decision ID, or explicit owner.
- Every `[PROPOSED]` architecture choice links to a `D-###` record.

## 6. Clarification priority

Prioritize unresolved items by irreversible cost and risk:

1. safety, legal, privacy, money movement, destructive actions;
2. authentication, authorization, tenancy, ownership, and data boundaries;
3. mutually exclusive product scope or actor definitions;
4. external contracts and irreversible architecture decisions;
5. data lifecycle, migration, retention, and recovery;
6. acceptance behavior and failure handling;
7. visual, copy, and low-cost implementation preferences.

When not in interactive mode, do not ask about priorities 4–7 before producing the first PRD. Record proposals and questions instead.
