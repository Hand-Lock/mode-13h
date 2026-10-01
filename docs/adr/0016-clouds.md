# 0016. Clouds

Date: 2026-10-01
Status: Accepted

## Context

Vanilla cloud fog changed three times, and what reaches gbuffers_clouds
differs per version:

| Version | Vanilla cloud fog | What Iris passes |
|---|---|---|
| < 1.21 | terrain fog, spherical, blend to fog color | Sodium's cloud range (end = cloud distance · 8, start = end − 16), not the terrain fog |
| 1.21–1.21.1 | terrain fog, view-space cylinder (`FogShape`), blend to fog color | world fog; clouds.png textured |
| 1.21.2–1.21.5 | terrain fog, world-aligned cylinder (`FogShape`), blend to fog color | world fog |
| ≥ 1.21.6 | `α *= 1 − linear(d, 0, cloudEnd)`, no fog color; cloudEnd = Cloud Distance · 16 (capped at 2048 from 1.21.11), or the environmental fog end in water, lava, powder snow, blindness or darkness | environmental fog; face colors with α 0.8 times CloudColor's α 0.8 |

On 1.21.1 clouds don't render at all with any pack. Sodium 0.8 replaces the
vanilla cloud renderer with its own `clouds` shader. Iris 1.7 (1.20.1)
redirected that to `CLOUDS_SODIUM`; Iris 1.8.14 dropped the mixin and does
not disable Sodium's cloud renderer, so the unknown shader is skipped
(`allowUnknownShaders=false`) and gbuffers_clouds never runs.

## Decision

- Mimic vanilla per version with an `#if MC_VERSION` ladder in
  gbuffers_clouds, using `fogRamp()` from fog.glsl (ADR 0017) so the FOG_*
  scales apply.
- Before 1.21, rebuild vanilla's terrain fog from `far`: end = max(far, 32),
  start = end − clamp(end/10, 4, 64); blindness lerps end toward 5 with
  start = end/4, darkness toward 15 with start = 0.75·end. Under water, lava
  or powder snow Sodium matches vanilla, so Iris's range is used. Nether
  thick fog is skipped: the dimensions that have it draw no clouds.
- On 1.21.6+, divide α by 0.8 to undo Iris's duplicate, then fade alpha
  to cloudEnd = min(CLOUD_DISTANCE · 16, 2048). Iris has no uniform for
  the Cloud Distance video setting (2–128 chunks), so the player mirrors
  it in our menu; the default 128 is vanilla's default. The slider tops
  out at 2048 blocks, so the cap is also right before 1.21.11.
- Keep the texture sample (needed on the textured vanilla path), vertex
  color as the only shading, no lightmap, alpha test before fog.
- Leave 1.21.1 unpatched: it is an Iris bug outside the pack. The
  player-side workaround is `mixin.features.render.world.clouds=false` in
  `config/sodium-mixins.properties`; vanilla clouds then reach
  gbuffers_clouds.

## Consequences

- Clouds look like vanilla's on every version that draws them: fog-colored
  at the render-distance edge before 1.21.6, faded into the sky after.
- A changed Cloud Distance only matches if the player also changes
  CLOUD_DISTANCE. Before 1.21.6 the option does nothing: clouds take the
  terrain fog there.
