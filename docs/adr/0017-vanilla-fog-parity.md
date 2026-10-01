# 0017. Vanilla fog parity per version

Date: 2026-10-01
Status: Accepted

## Context

applyFog() used one fog for every version: a linear ramp over Iris's
fogStart/fogEnd, a horizontal-only cylinder, and exponential curves with a
density scale. Vanilla differs in each era:

- Before 1.21.6: `smoothstep(start, end, d)`, d spherical or the cylinder
  `max(length(xz), |y|)` when `FogShape` is 1. Iris passes vanilla's start,
  end and shape.
- 1.21.6+: linear, `max(linear(sphere, envStart, envEnd), linear(cylinder,
  far − clamp(far/10, 4, 64), far))`. Iris's fogStart/fogEnd are the
  environmental values only, so render-distance fog was missing.
- The sky on 1.21.6+ has its own fog: `max(linear(sphere, 0, skyEnd),
  cylinder ≥ skyEnd)`, skyEnd = min(far, 512), or the environmental end in
  water, lava, powder snow, blindness or darkness. Before 1.21.11 skyEnd is
  `far`; since far never exceeds 512, min() is right on all of 1.21.6+.
- The void (the dark disc below the horizon) uses the sky fog. Before
  1.21.6 Iris passes the sky's fogStart/fogEnd per draw; its fogShape −1
  makes us measure a sphere where vanilla uses the cylinder, about one
  block apart for a disc 16 blocks down. On 1.21.6+ vanilla measures the
  disc before `translate(0, 12, 0)` lifts it, and Iris tags the draw
  `VOID`, which got the terrain fog and stayed clear almost to the render
  distance.
- Stars and the sunset fan are never fogged.
- Some draws fade out instead of blending to the fog color, since their
  additive blend would make the fog color glow:
  - enchantment glint, `rgb *= 1 − f`, every version, no lightmap;
  - lightning, `rgba *= 1 − f`, every version, untextured;
  - glowing eyes and translucent emissive layers, `rgba *= 1 − f` before
    1.21.2, the fog-color blend since.
  Iris routes glint to gbuffers_textured and lightning to gbuffers_entities,
  which lit and blended them.
- The world border is never fogged.
- Vanilla fog is never exponential. Iris's EXP2 underwater fog is its own.

## Decision

- fog.glsl branches on `MC_VERSION` (12106): smoothstep or linear curve,
  sphere/cylinder by `fogShape` or the two-ramp max. fogMode and fogDensity
  are ignored.
- `fogRamp()` scales every start and end by FOG_START_SCALE and
  FOG_END_SCALE and keeps them at least a block apart, so 1.00 is vanilla.
- gbuffers_basic reads `renderStage`: no fog for stars and sunset, the sky
  ramp for the sky and the void on 1.21.6+, with the void's distance taken
  12 blocks below its drawn position.
- Add gbuffers_armor_glint and gbuffers_lightning with the fade. They differ
  from their fallbacks, as ADR 0004 requires. gbuffers_spidereyes fades
  before 1.21.2.
- gbuffers_textured skips fog when `renderStage` is `WORLD_BORDER`.
- Skip, as not worth a program or not detectable:
  - energy swirl and breeze wind fade before 1.21.2, but reach
    gbuffers_entities indistinguishable from the entity;
  - the end portal is fogged from 1.21.5, a tiny difference that would need
    blockEntityId;
  - crumbling is fogged from 1.21.6, but only within reach, where fog ≈ 0;
  - 1.21.11 boss and thick fog shorten the sky and cloud end to the
    environmental end; Iris has no uniform for it.
- Remove `FOG_DENSITY_SCALE`; it scaled a curve vanilla doesn't have.

## Consequences

- Fog matches vanilla on 1.20.1 and 1.21.1 and on newer versions, at the
  same 0.50 start default (ADR 0012).
- Removing an option is breaking: the next release is a major bump
  (ADR 0008).
