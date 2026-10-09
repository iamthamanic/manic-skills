# Retention pattern library

Canonical shapes for `@retention-graph-audit`. Use one primary pattern per video.

Inspired by public educational retention-carousel teaching (e.g. @marketing.shekhar). Skill name remains `retention-graph-audit`.

## Pattern cards

### 1. `weak_hook`

**Headline:** This means your hook is weak.  
**Annotation cue:** They swiped right here.  
**Shape:** Starts at 100%, steep drop in the first seconds, then low plateau.

**Fix the hook:**
- Say the payoff in the first sentence
- Steal a winning structure (study proven hooks)
- Make text, voice and visual say one thing

### 2. `idea_fail`

**Headline:** This means your video sucks.  
**Annotation cue:** Gone before the first word.  
**Shape:** Near-instant wipe from 100% to near-floor before the content begins.

**Fix the idea:**
- Pick a problem millions already lose sleep over
- Steal the topic from a proven outlier
- Stop explaining your service. Talk about their pain

### 3. `mid_cliff`

**Headline:** This means one moment lost them.  
**Annotation cue:** Something right here made them leave.  
**Shape:** Healthy early retention, then a sharp cliff mid-timeline.

**Fix that moment:**
- Cut the backstory nobody asked for
- Add a visual change every few seconds
- Repost as a trial reel until the cliff disappears

### 4. `value_ran_out`

**Headline:** This means your value ran out.  
**Annotation cue:** They stopped learning here.  
**Shape:** Holds through the open, then steady bleed without one dramatic cliff.

**Fix the value:**
- One problem per video. Not five.
- Give numbered steps they can screenshot
- Show a real number from a real result

### 5. `healthy`

**Headline:** And this is a good video.  
**Annotation cue:** They stayed till the end.  
**Shape:** Mild early dip, then high flat line to the end.

**What worked:**
- The hook made its promise in 2 seconds
- Every line earned the next one
- A real result with a real number

## Cliff detection (implementation sketch)

Given points `(t_i, r_i)` with `r` in 0–100:

1. Early window: `r_0 - r_(≈3s)` → hook/idea
2. Sliding window slope: `min_i (r_(i+w) - r_i) / Δt` for `t_i ≥ 5s` → mid_cliff if large negative
3. Else if end weak after decent hook → value_ran_out
4. Else if end strong → healthy

Tune thresholds to the account's median curve when possible.
