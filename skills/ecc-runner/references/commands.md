# ECC Runner — commands reference

## Start modes

| Command | `runMode` | Behavior |
|---------|-----------|----------|
| `@ecc-runner` / `/ecc-runner` | `batch` | Full queue: all phases per issue, one final report |
| `ecc-runner continue` | `batch` | Resume batch from `state.json` |
| `issues abarbeiten` | `batch` | Same as `@ecc-runner` |
| `ecc-runner step` / `@ecc-runner step` | `step` | **One phase only**, then report |
| `ecc-runner status` | — | Snapshot only, no work |

## Triage overrides (before or during batch)

| Command | Action |
|---------|--------|
| `ecc-runner triage 42` | `agent-ready` on #42 (priority boost), rebuild queue |
| `ecc-runner triage P0` | `agent-ready` on all P0 |
| `ecc-runner milestone phase-2` | Filter queue by milestone |
| `ecc-runner queue` | `sync-queue-to-state.sh` |

## Flow control (pauses batch)

| Command | Action |
|---------|--------|
| `ecc-runner skip` | Release lock, defer issue, continue batch with next |
| `ecc-runner pause` | Stop batch after current phase; `paused: true` |
| `ecc-runner unblock 42` | Clear blockers; `ecc-runner continue` to resume batch |
| `ecc-runner cancel 42` | Abort issue #42 |
| `ecc-runner resume 42` | Adopt #42 as active |

## Ship (included in batch per issue)

| Command | Action |
|---------|--------|
| (automatic in batch) | `@commit-push-safe` then `@commit-pr-safe` with `Closes #N` |
| `ecc-runner commit` | Force commit phase only (step debug) |
| `ecc-runner pr` | Force PR phase only (step debug) |

## German triggers

`issues abarbeiten`, `offene issues`, `github issues`, `issue queue` → **batch mode**

`nächstes issue` alone → **batch continue**

## Stale lock

`stale-lock-check.sh` → fix → `ecc-runner continue` (batch resumes)
