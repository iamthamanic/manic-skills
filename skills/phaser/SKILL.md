---
name: phaser
description: >-
  Phaser 4 skill router for monster-pet-arena and other Phaser projects.
  Classifies the task, picks the minimal official phaserjs subskills, and
  requires reading them before coding. Use when the user invokes @phaser,
  /phaser, or asks about Phaser 4 scenes, sprites, physics, input, audio,
  tilemaps, cameras, tweens, filters, particles, UI text, loading, scaling,
  migration, or RenderNodes. For greenfield Game/GameConfig bootstrap only,
  use phaser-game-setup-and-config instead (do not route setup through this skill).
disable-model-invocation: true
---

# Phaser 4 — Skill Router

Entry point for Phaser 4 work. **Dispatch only** — do not re-teach engine APIs
here. Load the matched subskill(s), then follow them.

## Hard rules

1. **Phaser 4 only.** Never apply Phaser 3 patterns (`preFX`/`postFX`, Pipelines,
   BitmapMask, `Point`, Mesh/Plane) unless the active subskill explicitly shows
   a v3→v4 replacement.
2. **Setup is separate.** If the task is only creating `new Phaser.Game`, writing
   `GameConfig`, renderer/boot/FPS/pixel-art config → stop and load
   `phaser-game-setup-and-config` (or
   `$HOME/.agents/skills/game-setup-and-config/SKILL.md`). Do not route that
   through the table below.
3. **Read before code.** After routing, `Read` each selected `SKILL.md` (and any
   `references/` it points to) **before** writing or changing game code.
4. **Minimal set.** Load **1–3** subskills. Prefer the most specific match.
5. **No re-route spam.** Once subskills are loaded and the task stays in that
   domain, keep working from them. Re-run this router only when the concern
   clearly pivots (e.g. physics → audio).

## Routing algorithm

Copy and fill:

```
Phaser route:
- Task: <one line>
- Primary: <skill-dir>
- Secondary: <skill-dir | none>
- Tertiary: <skill-dir | none>
- Why: <one line>
```

Then resolve paths and read:

```
$HOME/.agents/skills/<skill-dir>/SKILL.md
```

If a skill is missing, install with:

```bash
npx skills add phaserjs/phaser@<skill-dir> -g -y
```

Full keyword map: [catalog.md](catalog.md)

## Quick route table

| If the task is about… | Load |
|---|---|
| v4-only APIs: Filters, RenderNodes, SpriteGPULayer, CaptureFrame, Gradient, Noise, Lighting, new tints | `v4-new-features` (+ `filters-and-postfx` if FX/mask) |
| Migrating v3 → v4, removed APIs, upgrade checklist | `v3-to-v4-migration` (+ `v4-new-features`) |
| Scenes, ScenePlugin, start/launch/stop, registry between scenes | `scenes` |
| Sprites, images, texture frames, atlas usage | `sprites-and-images` |
| Animations / AnimationManager / play/stop | `animations` |
| Arcade bodies, colliders, overlap, gravity | `physics-arcade` |
| Matter.js bodies, constraints, compounds | `physics-matter` |
| Keyboard, pointer, touch, gamepad | `input-keyboard-mouse-touch` |
| Cameras, follow, bounds, scroll, fade | `cameras` |
| Tilemaps, layers, tilesets, TilemapGPULayer | `tilemaps` (+ `v4-new-features` if GPU layer) |
| Audio, sounds, markers, unlock | `audio-and-sound` |
| Loader, preload packs, progress | `loading-assets` |
| Scale Manager, FIT/ENVELOP, resize, mobile fit | `scale-and-responsive` |
| Tweens, timelines, easing | `tweens` |
| Particles / emitters | `particles` |
| Text, BitmapText, retro fonts | `text-and-bitmaptext` |
| Graphics, shapes, geometry drawing | `graphics-and-shapes` |
| Groups, Containers, display lists | `groups-and-containers` |
| Filters, postFX replacement, FilterMask | `filters-and-postfx` (+ `v4-new-features`) |
| Components on game objects, mixins | `game-object-components` |
| Events, EventEmitter, scene events | `events-system` |
| Data Manager / `setData` / `data` values | `data-manager` |
| Time, clocks, delayed calls | `time-and-timers` |
| Curves, paths, followers | `curves-and-paths` |
| Math, Vector2, geom helpers | `geometry-and-math` |
| RenderTexture / stamp / bake | `render-textures` |
| Actions helpers, utility helpers | `actions-and-utilities` |
| New game / GameConfig / renderer / boot / FPS | **STOP** → `phaser-game-setup-and-config` |

## After loading

1. Follow the loaded skill’s instructions and examples.
2. Prefer Phaser 4 TypeScript patterns consistent with the project.
3. If docs may have drifted, also use Context7 / official Phaser 4 docs — do not invent APIs.
4. When done, briefly note which subskills were used (for the user).

## Invoke examples

- `@phaser add arcade collision between pet and arena walls` → `physics-arcade` (+ maybe `sprites-and-images`)
- `@phaser touch + keyboard move for mobile arena` → `input-keyboard-mouse-touch` (+ `scale-and-responsive` if fit)
- `@phaser replace glow FX with v4 filters` → `filters-and-postfx` + `v4-new-features`
- `@phaser-game-setup-and-config` (or “new Phaser.Game”) → setup skill only, not this router
