# 0009. Texture LOD matched to the output resolution

Date: 2026-09-28
Status: Accepted

## Context

gbuffers passes render at full window resolution, so the GPU picks mip levels
for that resolution. `final` then keeps one sample per `DOS_SCALE` cell, which
throws away the filtering: distant textures alias and shimmer as the camera
moves. A software renderer drawing at 320×200 would have picked its mip for
320×200.

## Decision

Every texture fetch goes through `albedo()` in `lib/common.glsl`, which biases
the LOD by `log2(DOS_SCALE)`. That selects the mip a renderer at the output
resolution would use. No option: at scale 1 the bias is 0.

## Consequences

- Less shimmer on distant terrain, no extra cost.
- Textures without mipmaps (entities, most GUI-like sprites) are unaffected.
- Cutout textures (leaves, plants) reach their averaged, lower-alpha mips
  sooner, so they can thin out a little earlier with distance, as they would
  at 320×200 in vanilla.
