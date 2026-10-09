---
name: retention-graph-audit
description: >-
  Diagnose short-form video audience-retention curves (Reels, TikTok, Shorts)
  into failure patterns — weak hook, idea fail, mid-video cliff, value ran out,
  or healthy retention — and prescribe concrete edit fixes. Use when the user
  mentions retention graph, audience retention, watch curve, drop-off, swipe
  rate, hook fail, retention cliff, Shekhar retention, retention-graph-audit,
  or wants to audit / classify a video retention chart for content improvement.
---

# Retention Graph Audit

Audit a short-form video's **audience retention curve** and turn the shape into a single diagnosis + fix list.

This skill is about **reading the curve**, not inventing metrics. Proxies alone (avg watch time, completion %) are not enough for cliff diagnosis — prefer a real second-by-second series when available.

Source framing for the pattern library: educational retention-carousel patterns popularized by @marketing.shekhar (Shekhar Shrestha). The skill name is `retention-graph-audit` — do not call the skill "Shekhar".

## When to use

- User pastes / describes / screenshots a retention graph
- Business Ultra / analytics pipeline has `retentionCurve[]` for a post
- User asks why a Reel/TikTok/Short died or held

## When NOT to use

- Only likes/views/ER available and no curve or screenshot → say data is insufficient; do not fake a cliff timestamp
- Long-form YouTube chapter strategy (different playbook) — still usable for Shorts / <90s clips

## Data gate (do this first)

Accept input in this order of quality:

1. **Curve series** — `[{ tSec | tRatio, retentionPct | audienceWatchRatio }, …]`
2. **Screenshot** of native Insights retention chart (with time labels on the x-axis)
3. **Coarse signals only** — avg watch, duration, skip/view rate → **pattern = inconclusive**; give directional hints only, label confidence `low`

Platform reality (do not invent APIs):

| Platform | Real retention curve? | Notes |
|----------|----------------------|--------|
| YouTube | Yes (Analytics API) | `elapsedVideoTimeRatio` + `audienceWatchRatio` |
| TikTok Business | Yes (Video Insights) | per-second retention when scopes allow |
| Instagram | App chart only | Graph API: avg watch + skip rate — no curve; use screenshot import |
| Metricool | Scalars only | Not a curve source |

Load `references/data-sources.md` when the user asks how to ingest curves into a product.

## Workflow

1. Normalize the curve to ~1s resolution (or ratio 0→1 mapped via duration).
2. Classify using `references/patterns.md` (exactly one primary pattern; optional secondary).
3. Emit the report format below.
4. If a cliff exists, name the **timestamp** and what to inspect in the edit at that second.

## Classification rules (summary)

Measure against the video's own length. Defaults assume short-form (~15–60s).

| Pattern ID | Shape | Primary label |
|------------|-------|----------------|
| `weak_hook` | Sharp drop in first ~0–3s (often to ~≤50%), then flat/low | Hook is weak |
| `idea_fail` | Near-vertical wipe in first ~1s ("gone before the first word") | Idea / topic fail |
| `mid_cliff` | Healthy early slope, then sudden steep drop mid-video | One moment lost them |
| `value_ran_out` | Holds into mid, then progressive bleed without a single spike cliff | Value ran out |
| `healthy` | Mild early dip, then high flat plateau to the end | Good video |

Heuristic helpers (tune per account baseline when available):

- **Early cliff:** Δ retention from t=0→3s ≥ 40–50 pp → `weak_hook` or `idea_fail` (idea_fail if wipe is essentially instant / before spoken payoff).
- **Mid cliff:** max negative slope in a 2–4s window after t≥5s, drop ≥ 25–30 pp → `mid_cliff` at that window.
- **Value bleed:** no single window qualifies as cliff, but retention at 50% duration already ≤ ~55% and end ≤ ~40% after a decent hook → `value_ran_out`.
- **Healthy:** after first 3s still ≥ ~70–80%, end retention still strong (roughly ≥ ~60–70% for short clips) → `healthy`.

Always prefer account baseline over absolute % when the user provides it.

## Fix playbooks (attach to pattern)

### `weak_hook` — Fix the hook

- Say the payoff in the first sentence
- Steal a winning hook structure (proven outliers)
- Make text, voice, and visual say one thing in the opening

### `idea_fail` — Fix the idea

- Pick a problem millions already lose sleep over
- Steal the topic from a proven outlier
- Stop explaining your service — talk about their pain

### `mid_cliff` — Fix that moment

- Cut the backstory nobody asked for (at the cliff second)
- Add a visual change every few seconds through that segment
- Repost as a trial Reel/cut until the cliff disappears

### `value_ran_out` — Fix the value

- One problem per video. Not five.
- Give numbered steps they can screenshot
- Show a real number from a real result

### `healthy` — What worked (reinforce)

- The hook made its promise in ~2 seconds
- Every line earned the next one
- A real result with a real number

## Output format

```markdown
## Retention Graph Audit

- **Video:** <title or id>
- **Platform:** <ig|tiktok|youtube|unknown>
- **Duration:** <Ns>
- **Data quality:** high (curve) | medium (screenshot) | low (proxies)
- **Primary pattern:** `<id>` — <one-line label>
- **Cliff / focus:** <timestamp or "none"> — <what happened>
- **Confidence:** high | medium | low

### Evidence
- Early (0–3s): …
- Mid: …
- End: …

### Fixes
1. …
2. …
3. …

### Next test
- <one concrete re-edit or A/B to run>
```

## Guardrails

- Do not claim Metricool (or similar aggregators) expose per-second curves unless verified.
- Do not scrape Instagram private Insights via undocumented GraphQL; prefer official APIs or user-supplied screenshots.
- One primary pattern per audit; stacking every fix list dilutes action.
- Attribute inspirational framing to the public educational pattern set; do not imply endorsement or affiliation.
