# 0010. Palettes: ramp and stock VGA through one raw 3D LUT

Date: 2026-09-28
Status: Accepted

## Context

ADR 0006 chose a fixed 256-color palette looked up through a LUT, and left
open which palette and how to store the LUT. Colormap lighting (R2) needs a
palette with brightness ramps. The stock VGA palette is the most "Mode 13h"
choice, but its ramps are few and cold.

## Decision

- Two palettes, as plain text of 6-bit DAC values in `tools/palettes/`:
  - **Ramp** (default): 16 families × 16 shades, Quake-style. Family 0 is a
    black-to-white gray ramp; the others run from dark up to a Minecraft key
    color (stone, dirt, wood, sand, grass, foliage, water, sky, red, lava,
    gold, amethyst, skin, diamond, crimson) at shade 11, then toward white.
  - **VGA**: the stock BIOS palette (EGA colors, grays, 3 intensities ×
    3 saturations × 24 hues, black).
- `tools/palette.sh` (POSIX sh, awk, `xxd`) maps each color of a 32³ grid to
  the nearest entry in OKLab and writes both LUTs, stacked on z, into one raw
  RGBA8 3D texture, `shaders/textures/palette.dat` (32×32×64, 256 KB). The
  file is generated but committed, so the pack needs no build step.
- `shaders.properties` loads it with `customTexture` as `TEXTURE_3D`, which
  Iris documents for raw textures. `palettize()` in `lib/palette.glsl`
  rounds the color to the grid and does one `texelFetch`.
- `DOS_PALETTE`: 0 off, 1 ramp, 2 VGA, 3 RGB332, 4 6×6×6. Off replaces the
  old bypass switch.

## Consequences

- One fetch per output pixel; no per-pixel search.
- The grid rounds each channel to 1/31 before the lookup. Two colors that
  close are nearly always the same palette entry anyway.
- Editing a palette means editing its text file and rerunning
  `tools/palette.sh`; `tools/check.sh` only checks the LUT's size.
- `DOS_PALETTE_256` and `DOS_PALETTE_BYPASS` are gone (major version).
- The raw 3D texture is the part most likely to differ between Iris and
  Oculus; it needs an in-game check on both.
