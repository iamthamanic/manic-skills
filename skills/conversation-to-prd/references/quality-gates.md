# PRD quality gates

## Contents

1. Gate policy
2. Mandatory gates
3. High-risk blockers
4. Reference anchors

## 1. Gate policy

Evaluate the PRD as an implementation contract, not as persuasive prose.

- `Pass`: evidence is present and internally consistent.
- `Fail`: required evidence is missing, contradictory, or unverifiable.
- `Not applicable`: the section was explicitly evaluated and a concrete exclusion reason is recorded.

Do not average failures into a numeric score. One high-risk failure can make the document `BLOCKED` even if every other section passes.

## 2. Mandatory gates

### Evidence integrity

- Every material confirmed claim cites one or more `S-###` sources.
- Inferences and proposals remain labeled.
- Later generated prose is never used as independent evidence.
- Conflicts are visible and linked to decisions.
- Repository, URL, version, and external-standard claims were inspected when relied upon.

### Product completeness

- Problem, affected user, current alternative, solution boundary, outcome, metric, non-goals, MVP, constraints, and dependencies are explicit.
- Output and outcome metrics are not confused.
- Scope does not silently expand through architecture or UI sections.

### Behavioral completeness

- Actors and authorization boundaries are explicit.
- Journeys include entry, success, failure, recovery, and final state.
- Requirements are atomic and observable.
- Acceptance scenarios cover happy, negative, boundary, permission, retry, and recovery behavior where applicable.
- Destructive operations specify confirmation, idempotency, audit, recovery, and irreversible point.

### UX completeness

- Screen/route inventory maps to journeys and requirements.
- Loading, empty, error, success, disabled, focus, offline, and permission-denied states are covered where applicable.
- Responsive and input-mode behavior is specified.
- Style references say what to adopt and what not to copy.
- Tokens or concrete rules replace vague aesthetic adjectives.
- Accessibility target and verification are explicit.

### Data and contract completeness

- Entities have owners, identifiers, types, nullability, validation, lifecycle, retention, and deletion behavior.
- Invariants and state transitions are explicit.
- Contracts cover auth, input, output, validation, errors, idempotency, ordering, pagination, versioning, and compatibility where applicable.
- Timezones, localization, numeric precision, currency, and personally identifiable information are evaluated.

### Architecture completeness

- Current state and target state are distinct.
- System, container, component, data-flow, and deployment boundaries are detailed only to the level needed.
- Trust, scaling, and failure boundaries are visible.
- Integration timeouts, retries, duplicate delivery, reconciliation, and fallback are defined.
- Tech choices are confirmed constraints or labeled decisions with alternatives and consequences.
- Repository layout communicates module responsibility, public interface, dependency direction, and test location.

### Security and privacy

- Authentication and authorization are not conflated.
- Server-side enforcement points are named for privileged actions.
- Tenant and ownership isolation is defined.
- Input, output, file, secrets, dependency, audit, abuse, and incident controls are evaluated.
- Data purpose, minimization, consent where applicable, retention, deletion, access/export, processors, and prohibited telemetry are explicit.
- Applicable controls cite a versioned standard when the project requires compliance evidence.

### Quality measurability

- Each `NFR-###` identifies stimulus, environment, metric, target, and verification.
- Latency specifies percentile and measurement point; availability specifies window; capacity specifies load shape; durability specifies loss tolerance.
- Proposed targets are not presented as user-confirmed.
- Cost and operational ownership are evaluated, not deferred automatically.

### Analytics and observability

- Each product metric supports a decision.
- Events have stable names, trigger semantics, required properties, consent treatment, and prohibited sensitive properties.
- Operational signals cover critical user journeys and dependency failures.
- Alerts have thresholds, routing, and runbook ownership.

### Verification completeness

- Every `FR-###` has at least one acceptance scenario and test.
- Every `NFR-###` has a verification method.
- Contract, authorization, accessibility, performance, and recovery behavior have appropriate test coverage.
- Test data covers roles, lifecycle states, boundary values, and failure injection without using production secrets or personal data.

### Delivery and operations

- Delivery slices produce vertical user value.
- Migration/backfill, rollout, compatibility, feature flags, rollback, and operational readiness are evaluated.
- Release acceptance is evidence-based.
- Owners are named or explicitly unknown for incidents, data operations, and high-risk decisions.

### Traceability

- Every goal links to requirements.
- Every requirement links to scenarios/tests and source evidence.
- Every screen, component, entity, endpoint, and event maps back to a requirement.
- Every risk has mitigation, contingency, acceptance, or owner.
- No orphan IDs or duplicated IDs exist.

## 3. High-risk blockers

Set the final status to `BLOCKED` when any unresolved item affects:

- safety-critical behavior;
- legal or regulatory obligations that determine the design;
- money movement, billing correctness, or entitlement ownership;
- irreversible deletion, retention, or migration;
- authentication, authorization, tenancy isolation, or privileged administration;
- storage or transmission of sensitive data;
- mutually exclusive definitions of the core user, problem, or MVP;
- an external contract whose unknown behavior determines correctness.

Use `READY WITH ASSUMPTIONS` when implementation can proceed reversibly and all assumptions are explicit, testable, and isolated behind configurable boundaries.

## 4. Reference anchors

Use these as method anchors, not as automatic compliance claims:

- OpenAI Build Skills: focused workflows, clear triggering, progressive disclosure, realistic testing. https://learn.chatgpt.com/docs/build-skills
- GitHub Spec Kit: specification-driven phases and clarification/analysis quality gates. https://github.com/github/spec-kit
- Cucumber Gherkin: structured executable scenarios using Feature, Rule, Scenario, Given, When, and Then. https://cucumber.io/docs/gherkin/reference/
- OpenAPI Specification: machine-readable, language-agnostic HTTP API contracts. https://spec.openapis.org/oas/
- C4 model: hierarchical system context, container, component, and supporting diagrams. https://c4model.com/
- Michael Nygard ADRs: context, decision, status, and positive/negative consequences. https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- Google SRE: quantitative SLIs and target SLOs for user-relevant service behavior. https://sre.google/sre-book/service-level-objectives/
- OWASP ASVS: versioned, testable application-security requirements. https://owasp.org/www-project-application-security-verification-standard/
- W3C WCAG 2.2: technology-independent, testable accessibility success criteria. https://www.w3.org/TR/WCAG22/
- NIST Privacy Framework: privacy-risk identification and management. https://www.nist.gov/privacy-framework
- OpenTelemetry semantic conventions: consistent names and attributes across telemetry signals. https://opentelemetry.io/docs/specs/semconv/
- Design Tokens Format Module: interoperable representation of design-system tokens. https://www.designtokens.org/tr/2025.10/format/

Select only standards relevant to the product. Record the exact version/date used. External standards do not replace product-specific acceptance criteria.
