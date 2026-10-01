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
  water, lava, powder snow, blindness or darkness.
- Stars and the sunset fan are never fogged.
- Vanilla fog is never exponential. Iris's EXP2 underwater fog is its own.

## Decision

- fog.glsl branches on `MC_VERSION` (12106): smoothstep or linear curve,
  sphere/cylinder by `fogShape` or the two-ramp max. fogMode and fogDensity
  are ignored.
- `fogRamp()` scales every start and end by FOG_START_SCALE and
  FOG_END_SCALE and keeps them at least a block apart, so 1.00 is vanilla.
- gbuffers_basic reads `renderStage`: no fog for stars and sunset, the sky
  ramp for the sky on 1.21.6+.
- Remove `FOG_DENSITY_SCALE`; it scaled a curve vanilla doesn't have.

## Consequences

- Fog matches vanilla on 1.20.1 and 1.21.1 and on newer versions, at the
  same 0.50 start default (ADR 0012).
- Removing an option is breaking: the next release is a major bump
  (ADR 0008).
