# Slice rules (feature-intake)

## Size

- One vertical slice = one PR-sized unit (~200–600 LOC typical)
- Max ~5 acceptance bullets per issue; split if more
- If estimate > 800 LOC → split again

## Order

1. Schema / types / adapter interfaces (no UI)
2. Local path first when `stackProfile: scriptony-desktop`
3. Cloud/hybrid adapter second (separate issue if large)
4. UI shell after data path exists
5. Enhance / AI / jobs after CRUD stable

## Dependencies

- Use `dependsOn` in JSON for ordering before GitHub numbers exist
- After create, ensure body contains `Depends on #N`
- Never circular deps

## Labels

| Label | When |
|-------|------|
| `P0` | Blocks MVP or other slices |
| `P1` | MVP scope, not blocking |
| `P2` | Post-MVP in same epic |
| `needs-design` | UI placement or architecture still open — runner runs `@pingpong-solution` first |
| `agent-ready` | **Do not** set at intake — user or triage adds when slice is clear |

## MVP cut (Ponytail Rung 1)

Every intake must document what **does not** become an issue yet.

Reference PRD roadmap sections (e.g. MVP 0.1 only) explicitly in epic design.

## Typed-strict (mandatory in every slice)

- Acceptance must include Boy Scout: no type-system escape hatches on touched files
- Do **not** create issues whose Solution is “use `any` / `Any` / `# type: ignore` to unblock”
- Language patterns: `@typed-strict` + `.qa/project.yaml` → `typedStrict.languages`

## JSON draft shape

```json
{
  "epicSlug": "multi-voice-engine",
  "designPath": ".qa/design/multi-voice-engine.md",
  "defaultLabels": ["P1"],
  "issues": [
    {
      "title": "…",
      "featureSlug": "mve-schema",
      "priority": "P0",
      "labels": ["P0"],
      "dependsOn": [],
      "body": "## Intent\n…"
    }
  ]
}
```
