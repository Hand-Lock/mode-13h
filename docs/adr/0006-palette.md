# 0006. Palette: fixed 256-color palette through a LUT

Date: 2026-09-28
Status: Accepted (implemented as ADR 0010)

## Context

Mode 13h shows 256 colors picked from an 18-bit VGA DAC (6 bits per channel).
Games of the era used one fixed, hand-built palette with brightness ramps so
lighting could be done by table lookup. The pack currently quantizes each
channel independently (RGB332 or a 6×6×6 cube). That gives the right count but
not the right look: hues snap to a uniform grid, and dark tones band harshly.

## Decision

- The default becomes a fixed 256-entry palette, stored as a 3D-to-2D color
  lookup texture loaded through `shaders.properties` custom textures and
  sampled once in `final`.
- The LUT maps each quantized input color to its nearest palette entry in a
  perceptual space, computed offline, so the shader does one texture fetch.
- Palette entries are 6-bit per channel, like the DAC.
- RGB332 and 6×6×6 stay as options.
- The palette content (the stock BIOS palette versus a game-style palette with
  ramps) is decided when this is implemented; ramps are needed for R2
  colormap lighting.

## Consequences

- One extra texture and fetch in `final`; no per-pixel search.
- Adds a generated asset and a small generator script to the repo.
- Changing the default palette is a visible change (minor version).
