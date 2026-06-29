# Scoring Rubric

Score each starred repo 0–100 against **capabilities** from Step 1, not current project stack.

## Capability matching (0–50)

- **40–50:** Direct capability match (repo clearly solves same class of problem)
- **25–39:** Partial overlap (one sub-capability, reusable module)
- **10–24:** Lateral / pattern match (different domain, same structural idea)
- **0–9:** Weak or tangential

Use semantic reasoning on `description`, topics, README title — not only exact keywords.

## Metadata signals (0–30)

| Signal | Points |
|--------|--------|
| Topic overlap with capabilities | 0–15 |
| Description keyword/concept overlap | 0–10 |
| Primary language irrelevant for lateral hits | 0 (no penalty for "wrong" language) |

## Freshness & health (0–20)

| Signal | Points |
|--------|--------|
| Updated within 12 months | +10 |
| Not archived | +5 |
| Not a bare fork with no delta | +5 |
| Archived | −15 |
| Empty / no description | −5 |

## Lateral hit rule

After sorting, ensure **≥2 repos** in L2 from a **different domain** than the chat topic if they scored ≥35. Label them `lateral: true` in the report.

Examples:

- Chat: "HR onboarding workflow" → starred game "quest state machine" = lateral
- Chat: "MCP tools for agents" → starred "CLI wrapper with hooks" = lateral

## Thresholds

| Stage | Threshold |
|-------|-----------|
| L2 inclusion | score ≥ 25 |
| L3 inclusion | score ≥ 45, max 8 repos |
| Chat top picks | score ≥ 55, max 5 |

If no repo ≥ 25, report **"No strong match among N stars"** honestly.
