# 0007. Texture mapping: Quake-style perspective subdivision by default

Date: 2026-09-28
Status: Proposed

## Context

The current affine mapping blends from perspective-correct to fully affine UVs
by distance. Full affine on Minecraft's large quads warps much more than most
late-90s games did: Quake computed a perspective-correct UV every 16 pixels
and interpolated linearly between them, giving a subtle wobble instead of
heavy warping.

## Decision

- Default: per-span subdivision. Pass `uv/w` and `1/w` as `noperspective`
  varyings. In the fragment shader, find the span edges every N pixels at
  320×200 scale, use screen-space derivatives to get perspective-correct UVs
  at both edges, and interpolate linearly between them.
- Full affine (the current behavior) stays as an option; so does off.

## Consequences

- A few extra ALU ops and two varyings per fragment; no extra passes.
- Derivatives are per 2×2 quad, so span edges are approximate on small
  triangles; that should be invisible at 320×200.
- Changes the default look (minor version) and adds an option.
