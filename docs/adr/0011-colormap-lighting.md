# 0011. Colormap lighting by double quantization

Date: 2026-09-28
Status: Accepted

## Context

Doom and Quake stored textures as palette indices and lit them through a
colormap: a table giving, for each index and light level, the palette entry
nearest to that color darkened. Shading therefore stepped down the palette's
ramps, and textures never showed colors outside the palette. ADR 0006 hinted
at doing this with index math on a ramp palette, which would need a second
LUT (or a render target of indices) and would only work with ramp-shaped
palettes.

## Decision

Quantize twice, with the one LUT from ADR 0010:

1. `albedo()` snaps the tinted texel to the palette before lighting, so
   textures are "indexed", as they were on disk in those games.
2. Lighting (stepped by `DOS_LIGHT_STEPS`) and fog work in RGB as before.
3. `final` palettizes again. That is exactly how a colormap entry was built:
   nearest palette color to the darkened palette color.

`DOS_COLORMAP` (default on) turns step 1 off. It does nothing when
`DOS_PALETTE` is off. It applies to every textured program; for the unlit
ones (sky, clouds, spider eyes) it matches what `final` does anyway.

## Consequences

- One extra `texelFetch` per textured fragment; no new textures or passes.
- Works with any palette, not only ramp ones: with VGA or RGB332, shading
  snaps to whatever the palette offers.
- The texel is rounded to the 32³ grid before lighting, so very dark
  lighting can merge neighboring texture colors, as low colormap rows did.
