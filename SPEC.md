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
- **Palette** (`DOS_PALETTE`). A fixed 256-color palette looked up through a
  32³ OKLab nearest-color LUT (`textures/palette.dat`): the ramp palette
  (16 Minecraft hues × 16 shades, default), the stock VGA palette, the Mac OS
  system palette, or the world palette of a classic game (Wolfenstein 3D,
  Doom, Heretic, Hexen, Quake, Duke Nukem 3D, Daggerfall). RGB332 and a
  6×6×6 cube are computed; 0 turns the palette off. ADRs 0006, 0010, 0013.
- **Colormap lighting** (`DOS_COLORMAP`, default on). Textures snap to the
  palette before lighting, so shading steps down each color's ramp like
  Doom/Quake colormaps. ADR 0011.
- **Lighting.** Vanilla lightmap with an ambient floor (`AMBIENT_FLOOR`) and
  luminance quantized to `DOS_LIGHT_STEPS` (default 16) while keeping tint.
  `oldLighting=true` keeps vanilla face shading.
- **Texture mapping** (`DOS_TEXMAP`). Quake-style subdivision by default:
  perspective-correct every `DOS_SPAN` output pixels (default 16), linear in
  between. Full affine (faded in over the nearest 1.5 blocks) and
  perspective-correct are options. Billboards and hands stay
  perspective-correct. ADR 0007.
- **Texture LOD.** Mip selection is biased by `log2(DOS_SCALE)`, so textures
  are filtered for the 320×200 output instead of shimmering. ADR 0009.
- **Fog.** Vanilla fog curves and shapes, scaled by `FOG_START_SCALE`,
  `FOG_END_SCALE` and `FOG_DENSITY_SCALE`; the default starts fog at half the
  vanilla distance.
- **Billboards.** Cross plants, cave vines, hanging propagules, amethyst,
  chains, torches, bamboo and lanterns are rewritten in the terrain vertex
  shader into single camera-facing quads. Signs and Billy Boarding blocks are
  opt-in.
- **Hands.** Optional unlit "painted sprite" look (`HAND_FLATTEN`) and a 4×4
  ordered dither at macro-pixel scale (`HAND_DITHER`, strength, 0 = off).
- **Water.** Darker and more opaque in low light.

## Roadmap

Each item gets an ADR before it is implemented.

- **R5 — Extended billboarding** through the Billy Boarding resource pack.
- **R6 — Flatter Signs on 1.21.1+** (separate repo, `Hand-Lock/flatter-signs`).
- **R7 — Optional bespoke skybox** resource pack.

## Add-on contract

Add-ons are separate mods or resource packs that turn block models into
cross/hatch geometry so the terrain vertex shader can billboard them. ADR 0005.

- IDs **10950–10999** in `block.properties` are reserved for billboards and
  add-ons.
- **10956**: sign cross-models from Flatter Signs; toggle `FLATTER_SIGNS`.
- **10990**: cross/hatch models from Billy Boarding; toggle `BILLY_BOARDING`.
  Only horizontal diagonal faces are billboarded, keeping the (+x,+z) one of
  each pair; a face's offset from the block center along its normal becomes
  depth toward the camera, so layered crosses stay apart. Other faces are
  drawn as they are, with the alpha discard. The list tracks the blocks Billy
  Boarding ships cross models for; a block is added when its art lands.
  Falling blocks carry no ID, so their diagonal faces billboard whenever they
  exist, around their own center and without depth (ADR 0015). Known gap:
  blocks moved by pistons stay static crosses.
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
