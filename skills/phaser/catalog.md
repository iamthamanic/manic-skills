# Phaser 4 subskill catalog

Canonical installs live under `$HOME/.agents/skills/<dir>/SKILL.md`.
Source package: `phaserjs/phaser` on skills.sh.

## Always separate

| Call as | Dir | When |
|---|---|---|
| `phaser-game-setup-and-config` | `game-setup-and-config` (via alias skill) | `new Phaser.Game`, `GameConfig`, renderer, canvas, boot, FPS, pixel art |

## Official topic skills

| Dir | Triggers / keywords |
|---|---|
| `v4-new-features` | Phaser 4 features, RenderNode, SpriteGPULayer, TilemapGPULayer, CaptureFrame, Gradient, Noise, Lighting, new tint modes, RenderSteps |
| `v3-to-v4-migration` | migrate, upgrade, v3 to v4, removed API, Pipeline→RenderNode, preFX→filters |
| `scenes` | Scene, ScenePlugin, launch, start, stop, sleep, wake, scene swap |
| `sprites-and-images` | Sprite, Image, texture, frame, atlas, spritesheet |
| `animations` | Animation, create anim, play, chain, AnimationManager |
| `physics-arcade` | arcade, collider, overlap, velocity, gravity, body |
| `physics-matter` | matter, constraint, compound, rigid body |
| `input-keyboard-mouse-touch` | keyboard, cursor keys, pointer, touch, gamepad, drag |
| `cameras` | camera, follow, shake, fade, pan, zoom, bounds |
| `tilemaps` | tilemap, tileset, layer, Tiled, map collision |
| `audio-and-sound` | sound, music, audio sprite, markers, unlock audio |
| `loading-assets` | preload, this.load, pack, progress bar, asset key |
| `scale-and-responsive` | Scale Manager, FIT, ENVELOP, RESIZE, orientation, mobile |
| `tweens` | tween, timeline, ease, yoyo, counter |
| `particles` | particle, emitter, explode, frequency |
| `text-and-bitmaptext` | Text, BitmapText, font, label, HUD text |
| `graphics-and-shapes` | Graphics, arc, rect, fillPath, stroke |
| `groups-and-containers` | Group, Container, Layer, display list |
| `filters-and-postfx` | filters, FilterMask, glow, blur, internal/external filters |
| `game-object-components` | components, mixins, Transform, Depth, Flip, Size |
| `events-system` | events, emit, on, once, EventEmitter |
| `data-manager` | data, setData, getData, DataManager |
| `time-and-timers` | time, delayedCall, timeline time, clock |
| `curves-and-paths` | Curve, Path, follower, spline, bezier |
| `geometry-and-math` | Vector2, Rectangle, Circle, Line, math |
| `render-textures` | RenderTexture, draw, stamp, erase |
| `actions-and-utilities` | Actions, PlaceOnCircle, GridAlign, CallAll |

## Install / refresh

```bash
# all official skills
npx skills add phaserjs/phaser -g -y

# one skill
npx skills add phaserjs/phaser@physics-arcade -g -y
```

Browse: https://skills.sh/phaserjs/phaser
