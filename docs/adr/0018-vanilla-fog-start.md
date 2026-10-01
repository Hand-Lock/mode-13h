# 0018. Vanilla fog start

Date: 2026-10-01
Status: Accepted (replaces the start default of ADR 0012 and ADR 0017)

## Context

ADR 0012 set `FOG_START_SCALE` to 0.50 so fog started at half the vanilla
distance, and ADR 0017 kept that default. Since ADR 0017 the fog curve,
distance shape and render-distance fog follow vanilla on every version, so
the only thing left between the default look and vanilla was the halved start.

## Decision

`FOG_START_SCALE` defaults to 1.00. With `FOG_END_SCALE` at 1.00 too, the
default fog is exactly vanilla's. The option and its values are unchanged.

## Consequences

- Fog starts later and the near world is clearer than in 2.x.
- Players who liked the old look set Start Scale to 0.50.
