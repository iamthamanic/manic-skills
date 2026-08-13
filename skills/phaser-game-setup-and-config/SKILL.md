---
name: phaser-game-setup-and-config
description: >-
  Phaser 4 greenfield game bootstrap and GameConfig. Use when the user invokes
  @phaser-game-setup-and-config, creates a new Phaser.Game, configures renderer,
  canvas, scaling defaults, pixel art, FPS, boot sequence, or GameConfig
  sub-objects. Do not use for gameplay features (scenes/physics/input) — those
  go through the phaser router skill.
disable-model-invocation: true
---

# Phaser Game Setup and Config

Dedicated entry for **new game / GameConfig** work. Kept separate from the
`phaser` router on purpose.

## Required first step

Immediately `Read` the official skill (do not improvise config from memory):

```
$HOME/.agents/skills/game-setup-and-config/SKILL.md
```

Then follow it exactly for Phaser **4**.

## Scope

**In scope**
- `new Phaser.Game(...)`
- `GameConfig` (type, width/height, parent, backgroundColor, banner, …)
- Renderer choice, pixel art, roundPixels, antialias
- FPS / timing boot options
- Initial scene registration in config
- Related boot wiring called out by the official skill

**Out of scope → hand off**
- After the game shell exists, further feature work goes through `@phaser`
  (router), which loads topic skills (`scenes`, `physics-arcade`, …).
- Scale Manager deep-dives may also need `$HOME/.agents/skills/scale-and-responsive/SKILL.md`
  (the official setup skill links related skills — read those when it says so).

## If the official skill is missing

```bash
npx skills add phaserjs/phaser@game-setup-and-config -g -y
```

Then re-read `$HOME/.agents/skills/game-setup-and-config/SKILL.md`.

## Project note

Prefer TypeScript + the project’s existing Vite/bundler layout. Do not introduce
Phaser 3-only config keys when the official v4 skill shows a replacement.
