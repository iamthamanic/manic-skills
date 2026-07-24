---
name: zoom-out
description: Ascend one abstraction layer and map relevant modules, dependencies, and callers when the agent or user does not know an area of code well. Use when exploring unfamiliar code, asking for an architectural map, or before implementing in an unknown module — using the project's domain glossary vocabulary.
disable-model-invocation: true
---

# Zoom Out

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

## Instructions

1. Identify the starting file/module/symbol from the conversation or user argument.
2. Ascend **one** abstraction layer (not the whole system): package/feature boundary, not every transitive dep.
3. Map:
   - modules in the same boundary
   - primary callers / entry points
   - key dependencies (inbound/outbound)
4. Name relationships with the project's domain vocabulary (glossary in `AGENTS.md`, PRD, or ubiquitous language docs when present).
5. Keep the map short — enough to navigate, not a full architecture dump.
6. Then stop or hand back to `@search-first` / `@implement` — do not start coding unless asked.

## Source

Adapted from [mattpocock/skills zoom-out](https://www.skills.sh/mattpocock/skills/zoom-out) (published skill text; not present in current upstream tree — may have been retired in favor of other navigation skills).
