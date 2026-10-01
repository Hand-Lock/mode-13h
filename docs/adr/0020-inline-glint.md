# 0020. Inline enchantment glint on 26.3

Date: 2026-10-01
Status: Accepted

## Context

Up to 26.2, vanilla draws the enchantment glint as a separate additive pass,
which Iris runs through `gbuffers_armor_glint`. 26.3 draws it inside the
item's own draw instead (`ITEM_*_GLINT`, `ENTITY_SOLID_GLINT`,
`ARMOR_CUTOUT_NO_CULL_GLINT`): `core/item.fsh` and `core/entity.fsh` add
`g * g`, with `g = GlintAlpha * texture(GlintSampler, uv)`, after the
lightmap and before fog.

Iris maps those draws to `gbuffers_entities` and `gbuffers_hand`, defines
`IRIS_INLINE_GLINT` and injects `vec3 mc_sampleGlint()` (zero for draws
without a glint). The glint appears only if the pack calls it, so packs that
don't lose it on held, dropped and worn items. Armor trims still use the
separate pass and `gbuffers_armor_glint`.

On 26.2, enchanted items look dark in the hotbar with every pack. GUI items
are drawn after the world with vanilla's shaders, outside the window in
which Iris applies pack programs, so no pack code runs on them.

## Decision

- `inlineGlint()` in `lib/common.glsl` returns `mc_sampleGlint()` squared
  under `#ifdef IRIS_INLINE_GLINT` and zero otherwise. `gbuffers_entities`
  and `gbuffers_hand` add it after the lightmap and before fog, like vanilla.
- `gbuffers_armor_glint` stays: trims and every version up to 26.2 use it.
- The 26.2 hotbar darkening is an upstream Iris bug (Iris #3348). The README
  FAQ says so; the pack doesn't work around it.

## Consequences

- Without the macro (older Iris, Minecraft before 26.3) the code compiles to
  nothing, so 1.20.1, 1.21.1 and 1.21.11 are unchanged.
- The hand's glint is dithered and palettized with the rest of the viewmodel.
