# Mode 13h — spec

## Vision

Minecraft becomes the **video signal** of a mid/late-90s DOS 3D game running in
VGA Mode 13h: 320×200 pixels, a 256-color palette, software-rendered textures,
banded lighting and sprite-like decorations. The pack makes the signal, not
the monitor: no CRT, no scanlines, no aspect or non-square-pixel emulation.
The player stretches the window to 4:3 on their own display, as the
real hardware did.

## Output contract

- At a 1280×800 window with `DOS_SCALE=4`, the image is exactly 320×200: one
  sample per 4×4 cell.
- Other window sizes and scales work but aren't the reference.
- The GUI stays at native resolution and is never palettized.

## Principles

- **Heavily opinionated.** Defaults are the intended look; options exist to
  tune, not to turn it into another pack.
- **Era-accurate by default, but cheap.** When two techniques look about the
  same at 320×200, use the cheaper one.
- **Near-post-processing.** Start from vanilla rendering and change as little
  of the geometry pipeline as possible.
- **Minimal program count.** Rely on the Iris fallback chain (ADR 0004).

## Compatibility

| Target | Status |
|---|---|
| Iris (Fabric/NeoForge), Oculus (Forge) | Supported |
| OptiFine | Not supported |
| Minecraft 1.20.1, 1.21.1 | Mandatory: tested in-game before every release |
| Minecraft 1.21.2 – 1.21.11, 26.x | Best-effort |
| GLSL | `#version 410 compatibility`, the ceiling for macOS |

## Current features

- **Resolution.** `final` point-samples one texel per `DOS_SCALE` cell
  (1–8, default 4).
- **Palette.** RGB332 quantized in sqrt space (256 colors, default) or a
  6×6×6 cube (216 colors). A bypass exists for debugging.
- **Lighting.** Vanilla lightmap with an ambient floor (`AMBIENT_FLOOR`) and
  luminance quantized to `DOS_LIGHT_STEPS` (default 16) while keeping tint.
  `oldLighting=true` keeps vanilla face shading.
- **Affine texture mapping.** Terrain, water, entities and generic textured
  geometry blend from perspective-correct to affine UVs over distance
  (`DOS_AFFINE_NEAR`, `DOS_AFFINE_RANGE`). Billboards stay perspective-correct.
- **Fog.** Vanilla fog curves and shapes, with scale/offset tuning; the default
  starts fog at half the vanilla distance.
- **Billboards.** Cross plants, cave vines, hanging propagules, amethyst,
  chains, torches, bamboo and lanterns are rewritten in the terrain vertex
  shader into single camera-facing quads. Signs and Billy-Boarding blocks are
  opt-in.
- **Hands.** Optional unlit "painted sprite" look and a 4×4 ordered dither at
  macro-pixel scale.
- **Water.** Darker and more opaque in low light.

## Roadmap

Each item gets an ADR before it is implemented.

- **R1 — Fixed 256-color palette.** A fixed VGA palette through a LUT becomes
  the default; RGB332 and 6×6×6 stay as options. ADR 0006.
- **R2 — Colormap lighting.** Light bands index along the palette's ramps
  instead of scaling RGB, like Doom/Quake colormaps. Depends on R1.
- **R3 — Quake-style perspective subdivision.** Perspective-correct every N
  screen pixels, affine in between, as the default texture mapping. Full
  affine stays as an option. ADR 0007.
- **R4 — Texture LOD matched to 320×200.** Bias mip selection by
  `log2(DOS_SCALE)` so textures are filtered for the sample rate that is
  actually shown, instead of shimmering.
- **R5 — Extended billboarding** through the Billy-Boarding resource pack.
- **R6 — Flatter Signs on 1.21.1+** (separate repo, `Hand-Lock/flatter-signs`).
- **R7 — Optional bespoke skybox** resource pack.

## Add-on contract

Add-ons are separate mods or resource packs that turn block models into
cross/hatch geometry so the terrain vertex shader can billboard them. ADR 0005.

- IDs **10950–10999** in `block.properties` are reserved for billboards and
  add-ons.
- **10956**: sign cross-models from Flatter Signs; toggle `FLATTER_SIGNS`.
- **10990**: cross/hatch models from Billy-Boarding; toggle `BILLY_BOARDING`.
- Toggles default to off, because without the add-on these blocks have normal
  models and billboarding them would break them.
- Changing or removing an add-on ID is a major version bump.

## Non-goals

CRT, scanlines, bloom, shadows, PBR, SSAO, reflections, OptiFine support, any
modern effect a 1990s software renderer couldn't do.

## Distribution

- Modrinth project `X5nQ5C2A` (slug `mode-13h`), shader type, loader `iris`.
- GitHub `Hand-Lock/mode-13h`, one release per tag `vX.Y.Z`.
- License AGPL-3.0-only. Author HandLock_.
