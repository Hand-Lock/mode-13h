# 0015. Falling block billboards

Date: 2026-09-29
Status: Accepted. Amends ADR 0014.

## Context

A falling block (FallingBlockEntity) draws its block model outside the chunk
mesh. A Billy Boarding anvil is a cross model, so it fell as a static cross
and only billboarded once it landed.

Iris and Oculus (1.20.1 and 1.21.1) draw falling blocks with
`ShaderKey.MOVING_BLOCK`, i.e. gbuffers_block, which falls back to our
gbuffers_terrain. There they carry no block ID: `mc_Entity` is (-1, -1)
because only chunk meshing sets it, the `entityId` uniform is stale in
terrain-format programs, and `blockEntityId` is -1. `at_midBlock` is
garbage. `mc_midTexCoord`, `at_tangent` and the normal are valid, but in the
space of the buffer positions, which is view-rotated on 1.20.1 and
world-aligned on 1.21.1.

## Decision

- Recognize falling blocks by `renderStage == MC_RENDER_STAGE_ENTITIES`.
  Entities go to gbuffers_entities, so nothing else reaches terrain in that
  stage. The block-breaking overlay also has no ID, but draws in the DESTROY
  stage.
- Billboard their horizontal diagonal faces (the ADR 0014 rule), keeping the
  (+x,+z) one, in player space: normal, position and tangent go through
  `mat3(gbufferModelViewInverse) * mat3(gl_ModelViewMatrix)`, which holds on
  both versions.
- A face billboards around its own center, with no layer depth: without
  `at_midBlock` the block center is unknown. Anvil and dripstone crosses pass
  through the center, so nothing is lost.
- Always on, not gated on `BILLY_BOARDING`. The ID is unknown, and the
  vanilla blocks that can fall are boxes, apart from pointed dripstone, which
  is already billboarded when placed.

## Consequences

- Falling Billy Boarding anvils and falling pointed dripstone face the
  camera; sand, gravel, concrete powder, scaffolding and the dragon egg are
  unchanged.
- Blocks pushed by pistons stay static crosses. They also use MOVING_BLOCK,
  but in the block-entity stage, alongside real block entities (signs,
  banners, skulls at 45°) with the same missing ID. Telling them apart would
  rely on unbound-attribute defaults, for a push that lasts 0.1 s.
