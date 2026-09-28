# 0007. Texture mapping: Quake-style perspective subdivision by default

Date: 2026-09-28
Status: Accepted

## Context

The old affine mapping blended from perspective-correct to fully affine UVs
by distance. Full affine on Minecraft's large quads warps much more than most
late-90s games did: Quake computed a perspective-correct UV every 16 pixels
and interpolated linearly between them, giving a subtle wobble instead of
heavy warping.

## Decision

- `DOS_TEXMAP`: 0 perspective-correct, 1 subdivided (default), 2 affine.
- Subdivided: the vertex shader writes `uvq = (u/w, v/w, 1/w)` as one
  `noperspective` varying, which is linear in screen space. The fragment
  shader splits each row into spans of `DOS_SPAN` output pixels (default 16,
  like Quake), aligned to the final cells. It extrapolates `uvq` to both span
  ends with `dFdx`, divides there, and interpolates linearly in between.
  If an extrapolated end lies behind the eye (`1/w ≤ 0`), that fragment uses
  the perspective-correct UV.
- Subdivided UVs may stray at most 2 texels from the exact UV. Quake clipped
  spans to polygon edges; ours are extrapolated along the triangle's plane
  far past 1-block faces, and at grazing angles toward the plane's vanishing
  line, where `1/w → 0` and the UV runs off into other atlas tiles.
- Terrain and water also clamp the subdivided UV to the face's UV rectangle,
  `mc_midTexCoord ± |uv − mc_midTexCoord|` from the vertex shader, inset half
  a texel. Within 2 texels of a face's edge the cap alone still lets the UV
  cross into the neighboring atlas sprite, which shows as foreign-colored
  lines along block edges at grazing angles. The bounds are widened to
  include the exact UV, so a face whose mid isn't its center only loses some
  wobble. Other programs stay unclamped (particles have no `mc_midTexCoord`).
- Affine: `uvq = (u, v, 1)`. Surfaces closer than 1.5 blocks fade to
  perspective-correct so walls don't smear when you touch them. The old
  near/range sliders are gone.
- Billboards and first-person hands are always perspective-correct.

## Consequences

- One `vec3` varying, one `dFdx`, two divides per fragment; no extra passes.
- `uvq` is linear in screen space, so `dFdx` is exact even across triangle
  edges; spans are exact per row, like Quake's scanline spans.
- The UV is continuous across span edges, so mip selection has no seams.
  The cap keeps it continuous: the error is 0 at span ends and the cap is a
  continuous function of it. Normal-angle wobble stays under the cap.
- The cap costs one `textureSize` and a few ALU ops per fragment. Affine mode
  stays uncapped: heavy warping is its point.
- Changes the default look (at least a minor version); removes
  `DOS_AFFINE_ENABLE`, `DOS_AFFINE_NEAR` and `DOS_AFFINE_RANGE`.
