# Generator Handoff

The skill must produce a renderer-neutral deck specification first. The presentation tool is downstream.

## Canonical renderer-neutral block

Use this compact structure after the full deck specification:

```text
DECK TITLE: [title]
AUDIENCE: [audience]
OBJECTIVE: [objective]
TONE: [tone]
FORMAT: Presentation
ASPECT RATIO: 16:9 unless specified otherwise

SLIDE 1
TITLE: [takeaway headline]
CONTENT:
- ...
- ...
VISUAL: [information-design direction]

---

SLIDE 2
TITLE: [takeaway headline]
CONTENT:
- ...
VISUAL: [direction]

---
```

Include only presentation content and visual direction in this block. Keep internal reasoning, source audits, and evidence-gap commentary outside it unless the user wants them visible in the deck.

## Gamma mapping

When Gamma is the requested renderer and its connector is available:

- Send the complete relevant deck content, not a short meta-prompt that asks Gamma to rediscover the story.
- Use the canonical slide separators when the Gamma action supports explicit card breaks.
- Prefer a mode equivalent to generation/expansion when the user wants a premium designed Gamma and the supplied content is an outline or strategic brief; let Gamma use its native layout intelligence.
- Prefer a mode equivalent to preserving supplied slide content only when the deck copy has already been approved and exact slide boundaries matter more than visual reinterpretation.
- Pass audience, language, tone, card count, and aspect ratio only when known or requested.
- Use Gamma for layout, theme, visual treatment, spacing, and hierarchy; do not delegate factual invention to it.
- Avoid over-prescribing layouts. Do not force every slide into bento/card grids. Ask for premium Gamma-native B2B design with selective use of hero slides, split layouts, one-number proof, clean process diagrams, and dashboard concepts.
- For Halteverbot123/browo decks, pass explicit CI instructions based on the approved screenshots: dark navy `#1D2E52` / `#192643`, light blue `#4EB2E5` with support blues `#62A6DA` / `#6299D8`, coral CTA `#EC7C69` with stronger emphasis `#E7614C`, warm off-white backgrounds `#F9F8F9` / `#F7F6F6`, soft card fills `#FDFBFB` / `#F4EEEE`, and the red V signature used sparingly and intentionally.
- Instruct Gamma to emulate a premium landing-page / frontend-product aesthetic from the approved screenshots: bright canvas, dark navy type, coral CTA buttons, rounded cards, generous spacing, thin borders, minimal shadows, restrained blue accents.
- Choose a suitable Gamma-native theme when available. Prefer `tranquil` or `icebreaker`; fallback to `consultant`, `blue-steel`, or selective `marine`. Avoid playful, purple, neon, pastel, and generic startup themes.
- If the user has not approved AI-generated realistic images, set image generation to no images. Use Gamma-native icons, labels, diagrams, tables, and clean graphic compositions instead. Do not let Gamma create synthetic people, vehicles, offices, partner screenshots, certificates, or customer situations.
- Mark conceptual dashboards, demo metrics, and not-yet-live portal views as examples or concepts.

## Canva mapping

When Canva is the requested renderer and its connector is available:

- Convert the canonical deck into the presentation outline expected by Canva's current presentation-generation flow.
- Preserve slide order and takeaway titles.
- Include concise body content and visual direction under each slide in the outline.
- Use Canva's required outline-review / presentation-preparation step when the connector requires it.
- Respect a selected brand kit, brand template, or visual reference when the user requests one.
- Do not skip a connector-mandated review step merely because the content architecture is already complete.
- For Halteverbot123/browo decks, include the same CI restrictions as above and ask Canva to preserve slide boundaries, takeaway titles, bento layouts, and no unapproved AI-realistic imagery.

## Tool-neutral fallback

If the user has not chosen a renderer, return the canonical block and stop. It should be directly reusable in Gamma, Canva, PowerPoint generation, Google Slides generation, or another slide renderer with minimal transformation.

## Rendering boundary

The content skill owns:
- audience logic
- narrative
- slide selection
- slide titles
- slide copy
- evidence discipline
- visual communication intent

The renderer owns:
- theme
- typography
- layout implementation
- decorative styling
- asset placement
- final visual polish

Do not let the renderer rewrite the business logic unless the user explicitly requests creative reinterpretation.
