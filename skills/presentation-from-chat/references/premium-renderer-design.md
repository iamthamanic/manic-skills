# Premium Renderer Design

Use this for presentation generation in Gamma, Canva, PowerPoint, or similar renderers whenever the deck is prospect-facing, executive-facing, investor-facing, or otherwise needs to look premium.

## Core design principle

A premium deck looks intentionally art-directed, not mechanically assembled.

Do not over-prescribe every visual element. Give the renderer a clear aesthetic direction and enough freedom to use its strongest native layouts. Over-constrained slide-by-slide instructions often produce cheap, synthetic, template-noise results.

## Avoid the cheap AI-deck look

Reject or revise handoffs that produce:

- Many small equal cards on every slide.
- Generic icon grids repeated across slides.
- Decorative AI photos, synthetic people, fake offices, fake vehicles, or fake dashboards.
- Overloaded bento boards with no visual hierarchy.
- Heavy gradients, excessive shadows, glossy 3D objects, neon accents, or startup-purple defaults.
- Every slide using the same smart-layout pattern.
- Long title + paragraph + icon grid structure on most cards.
- Tiny source notes or captions that compete with the message.
- UI mockups that look like invented products unless explicitly labeled as concept.

## Approved taste reference

For Halteverbot123 / browo decks, the user-approved screenshots are the default taste reference. The renderer should aim for:

- warm off-white canvas
- dark navy typography
- coral CTA/buttons/chips
- restrained light-blue brand accents
- rounded high-end cards and forms
- clean landing-page-like compositions
- minimal shadows, thin dividers, generous spacing

This is more specific than simply “use the brand colors”. The deck should feel like a premium product/site designed by a strong frontend designer, not a slide generator.

## Premium visual system

Default to one of these composition families and rotate them intentionally:

1. Editorial hero: one strong headline, one short subline, one restrained visual metaphor or graphic system.
2. Split thesis: left headline and argument, right single diagram, KPI stack, or product/partner flow.
3. One-number proof: large metric as the hero, one sentence of implication, small source note.
4. Clean process: 3-5 large steps with generous spacing and minimal labels.
5. Boardroom dashboard: one elegant mockup with 3-4 KPIs, explicitly labeled when conceptual.
6. Contrast slide: current state vs partnered state, no more than 3 rows.
7. Pilot slide: 30/60/90 or Start/Messen/Skalieren timeline.
8. Closing ask: one decision, one recommended starting point, one next action.

Use negative space aggressively. A slide can be premium with only one sentence and one diagram.

## Text density rules

- Maximum 1 headline and 1 short support line on title/hero cards.
- Maximum 4 content blocks per normal slide.
- Maximum 6 short bullets only when the slide is a checklist or proof summary.
- Prefer 8-12 words per headline; avoid multi-line titles that feel like paragraphs.
- Replace paragraphs with short labels, verbs, and concrete nouns.
- If a slide needs a paragraph to explain itself, split the slide or move detail to speaker notes.

## Visual hierarchy rules

Each slide must have exactly one dominant visual anchor:

- a big number
- a journey line
- a clean diagram
- a mock dashboard
- a before/after comparison
- a single bold headline
- a pilot timeline

Do not make every point visually equal. The reader should know what to look at first in under one second.

## Gamma-specific guidance

When using Gamma as renderer:

- Prefer `textMode: generate` for premium visual reinterpretation unless exact legal/technical text must be preserved.
- Use `preserve` only for final approved copy where layout variation is less important.
- Use `cardSplit: auto` unless exact slide boundaries are mandatory.
- Use a high-quality Gamma-native theme close to the brand rather than fighting the default renderer with excessive instructions.
- Use `imageOptions.source: noImages` for brand-controlled decks unless approved real assets exist.
- If visual support is needed, use Gamma-native diagrams, tables, callouts, labels, and icons; do not request AI-generated realistic images.
- Pass fewer, sharper design instructions: premium B2B, editorial, spacious, boardroom-grade, restrained, no fake imagery.
- Do not instruct Gamma to create many bento cards on every slide. Ask for bento selectively.

Preferred Gamma themes for Halteverbot123 when no custom template exists:

- `tranquil` or `icebreaker`: preferred starting points for the light, premium screenshot-derived look.
- `consultant`: fallback when a more strategy/boardroom look is needed.
- `marine`: fallback only when a darker, more branded section style is useful, but keep most slides light.
- `blue-steel`: acceptable fallback for operational/tech sections.

Avoid themes that introduce purple, neon, playful startup gradients, pastel candy colors, decorative illustration systems, or a dark-heavy full-deck look.

## Handoff pattern for premium decks

Provide Gamma with:

1. The audience and desired decision.
2. The conversion spine.
3. The exact proof points that must not be changed.
4. The slide story in concise bullets.
5. A short premium art-direction block.
6. Permission to use Gamma-native layout intelligence.

Do not provide 10 dense slides full of final text plus rigid visual directions unless the user explicitly wants a wireframe. Do provide enough taste direction to reproduce the approved screenshot theme consistently.

## Premium quality gate

Before generating or returning a deck, ask internally:

- Would a senior partnership lead feel comfortable sending this cold?
- Does the first slide look like a business opportunity, not a generic service flyer?
- Is there one clear business model diagram?
- Does the partner benefit appear before company biography?
- Are the proof points concentrated, not scattered?
- Did the renderer receive enough freedom to make it look good?
- Did the handoff avoid fake imagery and fake screenshots?
