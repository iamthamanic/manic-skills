# Report Format

Use this structure for audit and verification reports.

# Mobile Performance Audit: [application]

## 1. Scope

- Mobile repository: [path or unavailable]
- Backend repository: [path or unavailable]
- Platform: [Capacitor version, Android]
- Frontend: [framework and version]
- Backend: [framework and version or unavailable]
- Mode: [audit, plan, implement, verify]
- Evidence sources: [code, commands, benchmark, production data]

## 2. Executive assessment

State the main conclusion in one short paragraph. Distinguish observed defects from missing measurement capability.

## 3. Architecture and ownership

Describe:

- mobile frontend boundary;
- Android-native boundary;
- backend boundary;
- observability and CI boundary.

## 4. Category status

| Category | Status | Evidence summary |
| --- | --- | --- |
| Startup | pass/partial/fail/not verifiable/not applicable | ... |
| Rendering | ... | ... |
| Network and sync | ... | ... |
| Lifecycle and background work | ... | ... |
| Memory and storage | ... | ... |
| Android benchmarks and build | ... | ... |
| Observability | ... | ... |
| Backend | ... | ... |
| CI governance | ... | ... |
| Privacy | ... | ... |

## 5. Findings

Use one block per finding.

### [MPA-001] [title]

- Severity: critical/high/medium/low/info
- Evidence: verified/likely/not verifiable/not applicable
- Status: open/resolved/partial/unchanged/regressed
- Repository: mobile frontend/android/backend/infrastructure/CI
- Location: exact file and line when available
- Observation: what exists or is missing
- Impact: concrete runtime or operational consequence
- Required change: exact remediation
- Verification: command, trace, benchmark, or runtime evidence needed to close it

Do not combine unrelated problems into one finding.

## 6. Missing measurement capability

List problems that cannot currently be measured reliably, such as no production telemetry, no physical benchmark device, no frame benchmark, or no backend tracing.

## 7. Ordered implementation plan

### P0: Release blockers

Only critical correctness, reliability, privacy, or severe battery issues.

### P1: Required foundation

Measurement, lifecycle, sync, background-work, and high-impact performance controls.

### P2: Optimization and governance

Baseline Profiles, deeper budgets, dashboards, and lower-priority improvements.

For every item state the target repository and expected verification.

## 8. Commands executed

List commands and result status. Include failures and skipped commands.

## 9. Limitations

State unavailable repositories, credentials, devices, production data, or unsupported assumptions. Do not claim a pass for anything not inspected.
