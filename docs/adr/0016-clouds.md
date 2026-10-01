# 0016. Clouds

Date: 2026-10-01
Status: Accepted

## Context

What reaches gbuffers_clouds differs per version:

| Path | Texture | vColor | Fog range Iris passes |
|---|---|---|---|
| 1.20.1, Iris + Sodium | none | face shade × cloud color, α 0.8 | cloud-specific: end = cloud distance · 8, start = end − 16 |
| 1.21.1, vanilla clouds (see below) | clouds.png | face shade × cloud color, α 0.8 | world fog |
| 1.21.11 / 26.x, vertex-pulled | none | Iris face colors (α 0.8) × CloudColor (α 0.8) | environmental (overworld 0 → 1024) |

Vanilla 1.21.6+ (`rendertype_clouds.fsh`) and Sodium's cloud shader fade
cloud alpha out with distance; neither mixes toward the fog color. We fogged
clouds toward `fogColor`, so on 1.21.11 / 26.x the clouds past the 1024-block
fog end became fog-colored shapes instead of fading into the sky: wrong at
sunset and night, and they hid the stars.

On 1.21.1 clouds don't render at all with any pack. Sodium 0.8 replaces the
vanilla cloud renderer with its own `clouds` shader. Iris 1.7 (1.20.1)
redirected that to `CLOUDS_SODIUM`; Iris 1.8.14 dropped the mixin and does
not disable Sodium's cloud renderer, so the unknown shader is skipped
(`allowUnknownShaders=false`) and gbuffers_clouds never runs.

## Decision

- Clouds fade out: `alpha *= 1 − fogFactor(fogDistance(viewPos))`, using
  whatever fog range Iris passes and the FOG_* scales. No fog color.
- Keep the texture sample (needed on the textured vanilla path), vertex
  color as the only shading, no lightmap, alpha test before fog.
- Leave 1.21.1 unpatched: it is an Iris bug outside the pack. The
  player-side workaround is `mixin.features.render.world.clouds=false` in
  `config/sodium-mixins.properties`; vanilla clouds then reach
  gbuffers_clouds.
- Leave Iris quirks alone: on 1.21.11 / 26.x clouds are about 0.64 opaque
  (α 0.8 twice) instead of 0.8, and the fog end is the environmental 1024,
  not vanilla's cloud fog end, which Iris doesn't expose.

## Consequences

- Clouds blend into the sky at their edge on every version that draws them.
- `fogDistance()` is shared by `applyFog()` and the cloud fade.
