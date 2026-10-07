# Implementation-ready PRD template

## Contents

1. Template rules
2. Document template
3. Requirement examples
4. Applicability rules

## 1. Template rules

- Translate headings and prose into the user's language.
- Keep all `<!-- prd-section:* -->` comments, canonical status tags, and stable IDs unchanged.
- Replace all instructional placeholders. Use `Not applicable — <reason>` when a section was evaluated and excluded.
- Use one Markdown file by default.
- Do not fill tables with empty rows merely to appear complete.

## 2. Document template

```markdown
# Product Requirements Document: <Product name>

<!-- prd-section:document-control -->
## 0. Document control

| Field | Value |
|---|---|
| Status | Draft / In review / Approved |
| Implementation readiness | READY FOR IMPLEMENTATION / READY WITH ASSUMPTIONS / BLOCKED |
| Version | 0.1 |
| Last updated | YYYY-MM-DD |
| Product owner | Known owner or `[UNKNOWN]` |
| Technical owner | Known owner or `[UNKNOWN]` |
| Target release | Confirmed target or `[UNKNOWN]` |
| Evidence cutoff | Latest included source/date |

### Change history

| Version | Date | Change | Source / decision |
|---|---|---|---|

<!-- prd-section:source-ledger -->
## 1. Evidence and source ledger

| Source ID | Source | Evidence summary | Reliability | Affected sections |
|---|---|---|---|---|

### Conflicts

| Conflict ID | Claim A | Claim B | Sources | Impact | Decision needed |
|---|---|---|---|---|---|

<!-- prd-section:summary -->
## 2. Executive summary

### Context

### Problem

### Proposed solution

### Value proposition

### Desired outcomes

| Goal ID | Outcome | Baseline | Target | Measurement window | Status / source |
|---|---|---|---|---|---|

### Non-goals

<!-- prd-section:constitution -->
## 3. Product constitution and constraints

### Durable principles

### Hard constraints

### Dependencies

### Glossary

| Term | Definition | Source |
|---|---|---|

<!-- prd-section:users -->
## 4. Users, actors, and stakeholders

| Actor / role | Job to be done | Need / pain | Access boundary | Success signal | Source |
|---|---|---|---|---|---|

### Accessibility and inclusion needs

### Stakeholder responsibilities

<!-- prd-section:scope -->
## 5. Scope and release boundary

### MVP / current release

### Later releases

### Explicitly out of scope

### Scope assumptions

<!-- prd-section:journeys -->
## 6. User journeys and process flows

### Journey J-001: <Name>

| Step | Actor | Trigger / action | Touchpoint | System state and data | Failure / recovery | Analytics |
|---|---|---|---|---|---|---|

### Alternate, admin, support, and destructive flows

### State model

Use a state table or Mermaid state diagram when state transitions are non-trivial.

<!-- prd-section:functional-requirements -->
## 7. Functional requirements

| ID | Requirement | Priority | Status | Rationale | Sources | Acceptance | Dependencies |
|---|---|---|---|---|---|---|---|

### Business rules and invariants

| Rule ID | Rule | Scope | Failure behavior | Source |
|---|---|---|---|---|

<!-- prd-section:scenarios -->
## 8. Acceptance scenarios

### SCN-001: <Observable behavior>

- Covers: `FR-001`
- Given: <precondition>
- When: <actor action or event>
- Then: <observable result>
- And: <state, data, side effect, or event assertion>

Include happy, negative, boundary, permission, retry, and recovery scenarios as applicable.

<!-- prd-section:edge-cases -->
## 9. Edge cases and failure behavior

| ID | Trigger / condition | Expected behavior | Recovery | Covered requirements / scenarios | Test |
|---|---|---|---|---|---|

Evaluate empty, null, malformed, duplicate, stale, maximum-size, concurrent, partial-failure, offline, timeout, retry, auth-expiry, permission-change, timezone, locale, device, accessibility, dependency-outage, and destructive-action cases as applicable.

<!-- prd-section:ux -->
## 10. Information architecture, UX, and style guide

### Information architecture and navigation

| Route / screen | Actor | Purpose | Entry conditions | Primary actions | Exit / next state | Requirements |
|---|---|---|---|---|---|---|

### Screen specifications

For each material screen define content hierarchy, layout regions, components, interactions, validation, responsive behavior, keyboard behavior, and loading/empty/error/success/disabled/focus/offline states.

### Design principles and references

| Reference ID | Asset / URL / product | What to adopt | What not to copy | Status / source |
|---|---|---|---|---|

### Design tokens

| Token group | Token | Value / rule | Usage | Status / source |
|---|---|---|---|---|

Evaluate color roles and contrast, typography scale, spacing scale, grid and breakpoints, radii, borders, elevation, iconography, illustration, motion durations/easing/reduced-motion, density, and theming.

### Component inventory

| Component | Variants | States | Behavior | Accessibility | Used on |
|---|---|---|---|---|---|

### Content design

Define voice, tone, terminology, labels, validation copy, empty states, error messages, confirmation language, localization, and formatting rules.

### Accessibility target

State the applicable standard and level, verification method, keyboard/focus rules, semantics, contrast, zoom/reflow, reduced motion, and assistive-technology expectations.

<!-- prd-section:data -->
## 11. Domain, data, and lifecycle model

### Entity relationship overview

Use a table or Mermaid ER diagram when relationships are non-trivial.

| Entity | Purpose | Owner / tenant | Key fields | Relationships | Lifecycle | Source |
|---|---|---|---|---|---|---|

### Field dictionary

| Entity.field | Type / format | Required | Default | Validation | Classification | Retention / deletion |
|---|---|---|---|---|---|---|

### Invariants and state transitions

### Data import, export, migration, backup, restore, and deletion

<!-- prd-section:security -->
## 12. Authentication, authorization, security, and privacy

### Authentication and session behavior

### Authorization matrix

| Resource / action | Role A | Role B | Anonymous | Enforcement point | Audit event |
|---|---|---|---|---|---|

### Tenant and ownership boundaries

### Threats and abuse cases

| Threat / abuse case | Asset | Boundary | Prevention | Detection | Recovery | Requirement |
|---|---|---|---|---|---|---|

### Privacy and data governance

Classify personal/sensitive data, purpose, lawful basis where applicable, consent, minimization, retention, deletion, export/access rights, residency, processors, and prohibited logging/analytics.

### Security controls

Cover input validation, output encoding, secrets, encryption, dependency risk, rate limits, file handling, auditability, secure defaults, and incident handling as applicable.

<!-- prd-section:architecture -->
## 13. Technical architecture

### Current-state evidence

### Target system context

Use a C4-style system context diagram when multiple actors or external systems interact.

### Containers and deployment units

| Container / unit | Responsibility | Technology | Data owned | Interfaces | Scaling / failure boundary | Status / source |
|---|---|---|---|---|---|---|

### Components and dependency direction

| Component | Responsibility | Inputs / outputs | Depends on | Must not depend on | Requirements |
|---|---|---|---|---|---|

### Data and event flows

Use a sequence or flow diagram only when ordering, trust boundaries, or asynchronous behavior matters.

### Integration behavior

Define authentication, timeouts, retries, backoff, idempotency, rate limits, partial failure, circuit breaking, reconciliation, and fallback per integration.

### Architecture decisions

| Decision ID | Status | Context | Decision | Alternatives | Positive consequences | Negative consequences | Sources |
|---|---|---|---|---|---|---|---|

<!-- prd-section:stack-repo -->
## 14. Tech stack and repository architecture

### Stack

| Layer | Technology / version | Purpose | Constraint or proposal | Rationale | Alternatives / trade-offs | Source / decision |
|---|---|---|---|---|---|---|

### Repository structure

```text
<Show only meaningful directories/files with responsibilities>
```

### Module ownership and boundaries

| Path / module | Responsibility | Public interface | Allowed dependencies | Tests | Owner |
|---|---|---|---|---|---|

### Environments and configuration

Define local, test, staging, and production parity; configuration sources; secret handling; migrations; seed data; build/test/lint commands; CI gates; and generated artifacts.

<!-- prd-section:contracts -->
## 15. API, event, and external contracts

### Contract principles

### Operations

| Contract ID | Operation / event | Auth | Input | Success output | Errors | Idempotency / ordering | Versioning | Requirements |
|---|---|---|---|---|---|---|---|---|

### Schemas and examples

Define field types, required/nullable behavior, validation, pagination, filtering, sorting, timestamps/timezones, error envelopes, compatibility, and deprecation. Use OpenAPI/JSON Schema/AsyncAPI artifacts when implementation requires machine-readable contracts.

<!-- prd-section:quality -->
## 16. Quality attributes and budgets

| ID | Quality | Stimulus / environment | Measure | Target | Verification | Status / source |
|---|---|---|---|---|---|---|

Evaluate performance, availability, reliability, durability, capacity, scalability, security, privacy, accessibility, compatibility, maintainability, testability, observability, portability, localization, sustainability, and cost. Include only applicable requirements or state why excluded.

<!-- prd-section:analytics-observability -->
## 17. Product analytics and observability

### Decision-oriented analytics plan

| Metric ID | Decision supported | Definition | Source event | Segment | Owner | Guardrail |
|---|---|---|---|---|---|---|

### Event taxonomy

| Event | Trigger | Required properties | Prohibited properties | Consent | Related requirements |
|---|---|---|---|---|---|

### Operational observability

| Signal | Log / metric / trace | Collection point | Threshold / SLO | Alert / dashboard | Runbook owner |
|---|---|---|---|---|---|

<!-- prd-section:testing -->
## 18. Verification and test strategy

| Test ID | Level | Requirement / scenario | Setup / fixture | Assertion | Environment | Automation |
|---|---|---|---|---|---|---|

### Test data and fixtures

### Manual and exploratory checks

### Release acceptance criteria

<!-- prd-section:delivery -->
## 19. Delivery, migration, rollout, and operations

### Vertical implementation slices

| Slice | User value | Included IDs | Dependencies | Exit evidence | Rollback boundary |
|---|---|---|---|---|---|

### Migration and backfill

### Feature flags and progressive rollout

### Backward compatibility and rollback

### Operational readiness, runbooks, support, and incident ownership

<!-- prd-section:risks-decisions -->
## 20. Assumptions, risks, and open decisions

### Assumptions

| ID | Assumption | Impact if false | Confidence | Validation method | Owner / deadline | Status |
|---|---|---|---|---|---|---|

### Risks

| ID | Risk | Likelihood | Impact | Mitigation | Contingency | Owner | Related IDs |
|---|---|---|---|---|---|---|---|

### Open decisions

| ID | Decision needed | Why it matters | Options | Recommended default | Blocking? | Owner / deadline |
|---|---|---|---|---|---|---|

<!-- prd-section:traceability -->
## 21. Traceability matrix

| Goal | Requirement | Scenario / edge | UI / component / contract | Data | Test | Metric | Source |
|---|---|---|---|---|---|---|---|

<!-- prd-section:readiness -->
## 22. Readiness assessment

### Final status

`READY FOR IMPLEMENTATION` / `READY WITH ASSUMPTIONS` / `BLOCKED`

### Blocking items

### Accepted proposed defaults

### Readiness gate results

| Gate | Pass / fail / not applicable | Evidence / unresolved item |
|---|---|---|
| Evidence integrity | | |
| Product completeness | | |
| Behavioral completeness | | |
| UX completeness | | |
| Data and contract completeness | | |
| Architecture completeness | | |
| Security and privacy | | |
| Quality measurability | | |
| Verification completeness | | |
| Delivery and operations | | |
| Traceability | | |

### Handoff instructions for the implementation agent

State what may be implemented, which decisions must remain configurable, which files/contracts should be created first, and which assumptions must not be promoted to fact without approval.
```

## 3. Requirement examples

Bad:

> The dashboard should be fast, modern, and secure.

Why it fails: it combines three qualities, provides no operating condition, has no metric, and is not verifiable.

Good:

| ID | Quality | Stimulus / environment | Measure | Target | Verification | Status / source |
|---|---|---|---|---|---|---|
| NFR-004 | Performance | Authenticated user opens dashboard under normal production load | p75 Largest Contentful Paint from real-user monitoring | ≤ 2.5 s over a rolling 28-day window | RUM dashboard and release performance test | `[PROPOSED]`; rationale: initial web-performance budget |

Bad:

> Users can manage projects.

Good:

| ID | Requirement | Priority | Status | Rationale | Sources | Acceptance | Dependencies |
|---|---|---|---|---|---|---|---|
| FR-012 | The system shall allow a project owner to archive an active project after explicit confirmation while preserving its audit history. | Must | `[CONFIRMED]` | Prevent accidental loss while removing inactive work from default views | S-008 | SCN-021, SCN-022 | BR-006, DATA-004 |

## 4. Applicability rules

The template is comprehensive, not blindly mandatory. Evaluate every section and use a reasoned `Not applicable` entry where needed.

- API contracts may be not applicable to a static, local-only artifact.
- Multi-tenant boundaries may be not applicable to a single-user local tool.
- Migration may be not applicable to a greenfield product with no existing users or data.
- SLOs may be minimal for a disposable prototype, but performance and failure behavior still need verification.
- Regulatory details must not be invented. State the known jurisdiction and data category, then flag legal validation.
- Repository structure is a proposal unless verified against an existing repository or explicitly confirmed by the user.
