# 0005. Billboarding via block IDs and a vertex rewrite; add-on contract

Date: 2026-09-28
Status: Accepted

## Context

DOS-era 3D games drew plants, torches and props as camera-facing sprites.
Minecraft draws them as crossed quads or small 3D models. Shaders can't change
a block's model, only move its vertices.

## Decision

- `block.properties` maps billboard blocks to IDs in 10950–10999, one ID per
  geometry category.
- `gbuffers_terrain.vsh` keeps one face of each cross, rotates it around the
  block center to face the camera, and moves the vertices of other faces off
  screen. Billboards skip affine mapping.
- Blocks with non-cross models are converted by companion add-ons that swap
  their models for cross/hatch geometry: Flatter Signs (mod, ID 10956) and
  Billy-Boarding (resource pack, ID 10990). Each has an off-by-default toggle.

## Consequences

- No mod is needed for the base pack; add-ons are opt-in.
- The add-on IDs are a public contract: renumbering them is a breaking change.
- Each new geometry category costs a vertex-shader branch, so prefer adding
  blocks to existing categories.
