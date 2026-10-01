# 0021. Golden Days compatibility

Date: 2026-10-01
Status: Accepted

## Context

Golden Days (GD) 16.4, base and alpha, replaces two models the terrain
vertex shader billboards by shape (ADR 0005):

- Seagrass and tall seagrass (10962): vanilla's four axis-aligned planes in
  a `#` become a plain `block/cross`. The seagrass branch culls per vertex on
  `mid.z < 0.0`; on a diagonal face `mid.z` changes sign within the face, so
  half of each quad collapses to the cull point and the triangles stretch
  across the screen.
- Hanging mangrove propagule (10952): a sapling cross with `"x": 180`,
  upside down on purpose. The UV flip meant for vanilla's model turns it
  back upright.

The rest of GD (bamboo, torches, lanterns, chains, flora, textures, falling
blocks, fire) matches what the shader expects.

## Decision

- An off-by-default `GOLDEN_DAYS` option remaps 10952 and 10962 to 10950
  (plain cross) at the top of `gbuffers_terrain.vsh`, before every branch.
- A toggle, not detection: shaders can't see which resource packs are
  loaded, and the vanilla and GD models carry the same block ID.
- Off by default: with vanilla models the remap would push seagrass's
  axis-aligned planes through the cross path, and flip propagules upside
  down.
- GD's Polytone-only options (cuboid bamboo, picture-perfect signs and
  potted saplings) are out of scope: the dev instances don't run Polytone,
  and none of them tear.
- Billy Boarding goes above GD in the resource pack list; both ship
  `block/flower_pot.json`.

## Consequences

- One more add-on toggle, same pattern as `FLATTER_SIGNS` and
  `BILLY_BOARDING`.
- Players who forget the toggle with GD still see torn seagrass.
