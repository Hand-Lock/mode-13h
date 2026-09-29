# 0014. Billy Boarding flat faces and layer depth

Date: 2026-09-29
Status: Accepted. Amends ADR 0005.

## Context

ADR 0005 billboards every horizontal face of a 10990 block and culls all but
the (+x,+z) one. Billy Boarding's ADR 0007 asks for more:

- Wall bells need axis-aligned plates that are drawn but not billboarded.
  The cull drops them.
- Potted plants are layered crosses (pot back, plant, pot front) on parallel
  planes. Billboarding recenters each layer on the same axis, so they become
  coplanar and z-fight.
- The pitcher crop mixes a 3D bulb with billboarded leaves.

## Decision

- Only horizontal *diagonal* faces of 10990 are billboarded: both normal
  components on the horizontal plane above 0.5 in magnitude. 45° faces
  (0.707) pass; axis-aligned faces (exactly 0) and 22.5° faces (0.38) don't,
  and the billboard math assumes 45° anyway.
- Every other 10990 face is drawn as it is, still with the alpha discard.
- A billboarded face's offset from the block center along its normal becomes
  depth toward the camera (positive = in front). The face is recentered on
  the block's axis as before, then pushed that far toward the viewer, so
  layers keep their order from every side.
- The block list uses `minecraft:bell` for all attachments and adds
  `minecraft:pitcher_crop`.

## Consequences

- Compatible both ways: a cross through the block center has zero depth
  and looks as before; older Mode 13h versions just cull the new flat faces.
- An off-center diagonal face used to billboard around its own center; now
  it billboards around the block's axis, pushed forward by its offset.
- Add-on authors get a plain rule: diagonal = billboard, anything else = as
  modeled, parallel layers = depth.
