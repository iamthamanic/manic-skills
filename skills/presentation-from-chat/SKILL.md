---
name: presentation-from-chat
description: >-
  Convert a conversation, discovery thread, notes, attachments, or mixed source material into a presentation-ready content architecture and slide-by-slide deck specification for Gamma, Canva, PowerPoint, or another presentation tool. Use when the user asks to turn a chat into a presentation, pitch deck, partner deck, sales deck, internal decision deck, proposal deck, research deck, project update, or presentation outline. For Halteverbot123/browo work, always apply the bundled CI style guide, conversion-deck rules, and premium renderer design rules unless the user explicitly supplies a different brand system. Do not use for PRDs or for slide rendering alone.
---
# Presentation from Chat

Transform messy conversational context into a concise, persuasive presentation specification. Act as a presentation strategist and information architect, not as a transcript summarizer.

## Core principle

A deck is an argument, not a storage format.

Do not try to preserve every fact from the conversation. Preserve the facts required to make the audience understand, believe, decide, or act.


## 0. Brand and conversion discipline

Before building slide content, determine whether the presentation is for Halteverbot123, browo GmbH, Halteverbot123.de, or a related partner/sales/internal business use. If yes, read and apply `references/halteverbot123-style-guide.md`. This is mandatory for both content specifications and Gamma/Canva handoffs.

If the deck will be sent to prospects, partners, investors, or customers before a live meeting, also read and apply `references/conversion-deck-principles.md` and `references/premium-renderer-design.md`. Treat the deck as a conversion asset and premium business artifact, not as a document archive.

Brand defaults for Halteverbot123 work:

- Use the approved screenshot-derived theme by default: dark navy `#1D2E52` / `#192643`, light blue `#4EB2E5` with support blues `#62A6DA` / `#6299D8`, coral CTA `#EC7C69` with stronger emphasis `#E7614C`, warm off-white backgrounds `#F9F8F9` / `#F7F6F6`, and soft card fills `#FDFBFB` / `#F4EEEE`.
- Avoid default Gamma/Canva theme colors, especially purple/indigo accents.
- Use the red V as signature/checkmark/section marker.
- Aim for the frontend/product-marketing aesthetic visible in the approved screenshots: premium bright canvas, rounded cards, dark navy headlines, coral CTA elements, restrained blue accents, minimal shadows, generous spacing.
- Use bento layouts, KPI tiles, dashboards, flows, and journey diagrams selectively; do not force every slide into the same grid/card pattern.
- Do not over-constrain Gamma/Canva, but do give explicit taste direction so the renderer lands close to the approved theme.
- Do not use AI-generated realistic photos or synthetic people unless the user explicitly approves them. Prefer diagrams, icons, UI mockups, and user-supplied/approved brand assets.
- Never invent logos, certification badges, screenshots, customer quotes, dashboard metrics, or performance data.

## Workflow

1. Build the presentation brief.
2. Extract and classify source material.
3. Choose the deck archetype and narrative spine.
4. Prioritize content and remove conversational noise.
5. Build the slide architecture.
6. Write presentation-ready slide content.
7. Run the quality gate.
8. Run the premium design gate for prospect-facing decks.
9. Produce the canonical deck handoff.
10. If explicitly requested, hand the approved content to Gamma, Canva, or another presentation connector.

## 1. Build the presentation brief

Infer the following from the conversation before asking for missing information:

- audience
- presentation objective
- desired audience action or decision
- core thesis
- presenter / organization
- context or occasion
- expected level of detail
- language
- tone
- constraints such as slide count, duration, brand, format, visual style, no-image rules, generator, or mandatory topics

Do not repeat questions already answered in the conversation. If a non-critical field is unknown, choose a reasonable default and list it under `Assumptions`.

If audience or desired outcome is genuinely impossible to infer and materially changes the deck, ask only the minimum necessary question. Otherwise proceed.

## 2. Extract and classify source material

Treat the current conversation and explicitly referenced attachments as the primary source set.

Create an internal evidence inventory with these classes:

- `FACT`: directly stated or supported by supplied material
- `DECISION`: something the user has chosen or approved
- `CLAIM`: a persuasive statement that may need evidence
- `METRIC`: quantitative evidence
- `EXAMPLE`: concrete illustration, case, scenario, or anecdote
- `OBJECTION`: concern the audience may have
- `BENEFIT`: audience value
- `DIFFERENTIATOR`: why this option, company, or approach is preferable
- `PROCESS`: how something works
- `ASK`: requested decision, action, or next step
- `OPEN_GAP`: information that would materially strengthen the deck but is absent

Do not expose this raw inventory unless it helps the user. Use it to construct the narrative.

### Evidence rules

- Never invent metrics, customer results, certifications, market data, quotes, or factual proof.
- Preserve exact numbers when they matter.
- Distinguish observed facts from inference.
- Mark unsupported quantitative or factual claims as `[RESEARCH NEEDED]` or weaken the wording.
- Use web research only when the user asks for research, when current external facts are required, or when a material claim must be verified.
- Keep source provenance for important claims so citations or source notes can be added later.

## 3. Choose the deck archetype

Read `references/deck-patterns.md` and select the closest archetype. For partner, affiliate, sales, or cold-outbound decks, also apply `references/conversion-deck-principles.md` and `references/premium-renderer-design.md`. Adapt it to the actual objective; do not force a template when the conversation implies a better structure.

Prefer one primary narrative spine. Avoid combining multiple deck types unless necessary.

## 4. Prioritize and compress

For every candidate point, test:

1. Does the audience need this to understand the situation?
2. Does it strengthen belief in the thesis?
3. Does it reduce an important objection or risk?
4. Does it support the requested decision or action?

If the answer is no to all four, remove it from the main deck.

Move useful but non-essential detail to an appendix instead of overloading the core story.

### Compression rules

- One slide = one main message.
- For cold outbound decks, the first three slides must make the reader care, understand the gain, and see that the next step is low effort.
- Prefer 2-5 supporting points per slide.
- Prefer a number, example, mechanism, or proof point over generic adjectives.
- Remove repetition inherited from the chat.
- Combine adjacent ideas only when they support the same takeaway.
- Split a slide when it contains two different conclusions.
- Default to 7-12 core slides when no length is specified; go shorter when the decision can be made with less.

## 5. Build the slide architecture

Write the slide titles first, before writing slide bodies.

Titles must be takeaway headlines, not topic labels.

Weak:
- `Benefits`
- `Market`
- `How it works`

Strong:
- `One integration creates a new revenue stream without adding operational work`
- `Parking scarcity makes moving-day access a predictable urban problem`
- `The partner only needs to refer the customer; fulfillment and tracking stay with us`

Read the titles in sequence. They should form a coherent executive summary of the whole deck.

### Slide roles

Use roles intentionally:

- hook / opening thesis
- context
- problem
- opportunity
- evidence
- solution
- mechanism / workflow
- benefit
- proof / credibility
- economics / business case
- comparison / alternatives
- risk / objection response
- implementation
- recommendation
- ask / next step
- appendix

Do not include a slide merely because a common template normally has it.

## 6. Write presentation-ready slide content

For each core slide provide:

### Slide N — [takeaway headline]

**Purpose**  
Why this slide exists in the argument.

**On-slide content**  
The actual concise content intended to appear on the slide. Use bullets, short statements, steps, or a compact table structure when appropriate.

**Proof / evidence**  
Numbers, facts, examples, source-backed claims, or `None required`. Flag missing proof explicitly.

**Visual direction**  
Describe the information design, not decorative art. Examples: three-step flow, before/after, funnel, simple comparison, map, KPI row, timeline, annotated product flow, dashboard mockup, bento KPI tiles, icon-supported benefit row. For Halteverbot123 work, specify CI colors, bento layout, red V usage, and whether visuals must avoid AI-generated realistic imagery.

**Source note**  
Identify where important facts came from: conversation, attachment, user-supplied source, or external research.

**Speaker note**  
Include only context that helps the presenter but should not clutter the slide. Keep it short.

### Copy rules

- Write for scanning, not reading like a document.
- Use plain, specific language.
- Prefer active voice.
- Avoid empty claims such as `innovative`, `seamless`, `best-in-class`, `game-changing`, or `unique` unless proven and necessary.
- Avoid paragraphs on slides unless the format explicitly calls for a quote or narrative passage.
- Do not repeat the title in the body.
- Preserve important terminology from the source material.
- Keep benefit language audience-centered.
- For partner decks, lead with commercial benefit, low effort, risk reduction, user value, and proof before service detail.

## 7. Quality gate

Before returning the deck, verify all of the following:

### Narrative
- The first 2-3 slides establish why the audience should care.
- The middle proves the thesis rather than merely describing it.
- The ending makes the desired action or conclusion obvious.
- The title sequence alone tells a coherent story.

### Relevance
- Every core slide contributes to the audience outcome.
- Chat history has been filtered rather than dumped into the deck.
- Supporting detail is moved to appendix when appropriate.

### Evidence
- Numbers and factual claims are traceable.
- Unsupported claims are marked or softened.
- No invented proof points appear.
- Current or time-sensitive claims are verified when required.

### Slide quality
- One dominant message per slide.
- On-slide copy is concise enough for a presentation.
- Visual direction reinforces the message instead of decorating it.
- No consecutive slides repeat the same argument.
- For Halteverbot123 decks, the visual handoff follows the CI: colors, typography intent, V signature, no unapproved AI-realistic imagery, and no default purple/indigo theme.
- For premium prospect-facing decks, the handoff avoids the cheap AI-deck look: no repeated card grids, no fake AI photos, no synthetic people, no decorative dashboard clutter, and no overuse of bento layouts.
- For Gamma, the handoff uses a suitable Gamma-native theme and allows visual reinterpretation unless exact slide boundaries are mandatory.

### Audience fit
- Benefits are framed from the audience's perspective.
- Likely objections are answered when material.
- The deck contains an explicit decision, recommendation, or next step when the objective requires one.

If the quality gate fails, revise before presenting the output.

## 8. Canonical output

Return the deck in this order.

# Presentation Brief

- **Working title:**
- **Audience:**
- **Objective:**
- **Desired action / decision:**
- **Core thesis:**
- **Tone:**
- **Recommended length:**
- **Source basis:**
- **Assumptions:**
- **Brand / visual rules:**

# Narrative Spine

Give 4-7 numbered sentences describing the logic of the presentation from opening to conclusion.

# Core Deck

Use the slide format defined above.

# Appendix Candidates

List relevant supporting slides that should not interrupt the main argument.

# Evidence Gaps

List only material gaps. For each gap state:
- what is missing
- why it matters
- whether research, internal data, or user input is the best source

# Generator Handoff

Read `references/generator-handoff.md` and produce a renderer-neutral handoff plus the appropriate Gamma or Canva mapping when requested.

## 9. Connector execution

Do not generate the final presentation in an external tool unless the user explicitly asks to create it there.

When the user asks only for `content`, `outline`, `presentation structure`, or `what should be in the deck`, stop after the canonical output.

When the user explicitly asks to create the presentation:

1. Finish and quality-check the canonical deck spec first.
2. Use the requested presentation connector if available.
3. Pass the complete relevant slide content and presentation brief, not a vague summary.
4. Preserve the slide boundaries and takeaway titles when the connector supports structured outlines or explicit card/page breaks.
5. Follow the connector's current required review, template, brand-kit, or generation flow rather than bypassing it.
6. Do not silently add unsupported facts during rendering.
7. Treat the external tool as renderer and layout engine; the narrative and content decisions come from this skill.

If no renderer is named, keep the output tool-neutral.

## Reference files

- `references/deck-patterns.md` — narrative structures for common presentation goals
- `references/generator-handoff.md` — canonical handoff format and Gamma/Canva mapping
- `references/halteverbot123-style-guide.md` — mandatory CI rules for Halteverbot123/browo presentations
- `references/conversion-deck-principles.md` — cold outbound and conversion deck structure
- `references/premium-renderer-design.md` — premium visual taste, Gamma-native rendering, and anti-cheap-AI-deck rules
