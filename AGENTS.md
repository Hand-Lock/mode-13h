# Mode 13h — agent guide

Mode 13h: MS-DOSify! is an Iris/Oculus shaderpack that turns Minecraft into the
video signal of a mid/late-90s DOS game running in VGA Mode 13h (320×200, 256
colors). It is deliberately small: a handful of gbuffers programs, one `final`
pass, no composites. Product direction lives in [SPEC.md](SPEC.md); decisions
and their reasons live in [docs/adr/](docs/adr/). Read both before changing
architecture, look or compatibility.

## Hard constraints

- Every program starts with `#version 410 compatibility`.
- Nothing from GL ≥ 4.2: no compute, SSBOs, image load/store,
  `layout(binding=)`, `textureQueryLevels`. macOS caps at 4.1.
- Iris and Oculus only. No OptiFine-specific code or claims.
- Must compile and run on Minecraft **1.20.1** and **1.21.1**. Newer versions
  are best-effort.
- Be cheap. Prefer the simplest technique whose result is indistinguishable.
- Emulate the signal, not the monitor: no CRT, scanlines, bloom or aspect
  correction. The player stretches to 4:3 themselves.

## File map

```
shaders/
  shaders.settings      option defines (the menu reads `// [values]`)
  shaders.properties    Iris directives, menu layout, sliders
  block.properties      block → mc_Entity ID map
  lang/en_us.lang       menu labels and tooltips
  lib/vertex.glsl       shared varyings; emitVertex() when VSH is defined
  lib/common.glsl       gtexture/lightmap samplers, applyLightmap()
  lib/fog.glsl          vanilla-compatible fog, applyFog(rgb, viewPos)
  lib/texmap.glsl       texmap(): perspective / subdivided / affine UVs
  lib/palette.glsl      quantize256() (RGB332), quantizeCube6() (216)
  gbuffers_*.vsh/.fsh   geometry passes, each writes colortex0
  final.vsh/.fsh        point-sampled 320×200 downscale + palette
tools/                  check.sh, build.sh, release.sh, modrinth.json
```

Pipeline: every gbuffers program writes lit, fogged color to colortex0.
Each .vsh is `#define VSH`, `#include "/lib/vertex.glsl"` and a call to
`emitVertex()`; the .fsh includes the same file for the varyings.
`final.fsh` takes one texel per `DOS_SCALE`×`DOS_SCALE` cell and quantizes it
to the palette. At 1280×800 with `DOS_SCALE=4` that is exactly 320×200.

Iris falls back when a program is missing:

```
textured_lit                                   → textured → basic
terrain, entities, hand, particles, weather    → textured_lit
water, block, damagedblock                     → terrain
entities_glowing                               → entities
hand_water                                     → hand
skytextured, clouds, spidereyes,
  beaconbeam, armor_glint                      → textured
skybasic, line                                 → basic
```

Never add a program whose code equals its fallback. Add one only when it must
behave differently.

## Adding a menu option

Four places, kept in sync (`tools/check.sh` verifies 1–3):

1. `shaders.settings`: `#define NAME default // [v1 v2 …]`
2. `shaders.properties`: put `NAME` in a `screen.*` list; add it to `sliders`
   if it is numeric.
3. `lang/en_us.lang`: `option.NAME=`, `option.NAME.comment=`, and
   `value.NAME.<v>=` for on/off or enum values.
4. The code that reads it, inside `#if`.

## Billboarded blocks

IDs 10950–10999 are reserved for billboards and add-ons (map at the top of
`block.properties`).

- **Same shape as an existing category** (a cross plant, a torch…): append the
  block name to that `block.<id>` line.
- **New shape**: pick a free ID in the range, document it in the header, add a
  branch in `gbuffers_terrain.vsh`, and check the `noAffine` range covers it.
- `block.properties` rules: comments go *above* a key, never between `\`
  continuation lines; nothing after a trailing `\`. Keep old and new block
  names side by side (Iris skips names the running version lacks).
- Add-on contract (see SPEC.md): 10956 = sign cross-models from Flatter Signs
  (`FLATTER_SIGNS`), 10990 = cross/hatch models from the Billy-Boarding
  resource pack (`BILLY_BOARDING`). Don't renumber these; add-ons depend on
  them.

## Task loop

For every task:

1. Implement it.
2. Run `tools/check.sh` and fix everything it reports. It compiles each
   program with glslang using the default option values, so also think about
   the other `#if` branches you touched.
3. Add a line under `## [Unreleased]` in `CHANGELOG.md` (Added / Changed /
   Fixed / Removed) if a player would notice.
4. Write an ADR in `docs/adr/` if the change decides something about
   architecture, look or compatibility (see ADR 0001).
5. Commit: imperative, concise subject; body only if the why isn't obvious;
   end with the co-author trailer your harness asks for.
6. `git push`.

Don't ask for screenshots or wait for an in-game check. The user tests on
their own and tells you when something is wrong.

## Visual verification

Only when the user reports a problem, or asks you to look. You can't see the
game: ask them to reload shaders in-game (default `R` in the shader screen, or
F3+R) and press F2, then read the newest screenshot:

```sh
sh -c '. ./.local.env; IFS=:; for d in $MC_DIRS; do
  ls -t "$d/screenshots"/*.png | head -1; done'
```

(`sh -c` because zsh doesn't split `$MC_DIRS` on `IFS`.)

`.local.env` is gitignored and holds `MC_DIRS`, a colon-separated list of
`.minecraft` directories of the dev instances (1.20.1 and 1.21.1). If it is
missing, ask the user for the paths and write it.

The dev instances load this repo as `shaderpacks/mode-13h-dev/`, a real folder
holding one symlink, `shaders`, to the repo's `shaders/`. Don't symlink the
pack folder itself: Iris's validity check walks the pack without following
links, finds no `shaders/` and rejects the pack ("is not valid").

## Release

Only when the user says **release**. Never on your own initiative.

1. Pick the SemVer bump: patch = fixes and block-list additions; minor = new
   features or visible look changes; major = removed/renamed options or a
   changed add-on ID contract.
2. Ask whether both 1.20.1 and 1.21.1 were tested in-game, unless the user
   already said so. Their word is enough.
3. In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`
   and add a fresh empty `## [Unreleased]` above it. Commit and push.
4. Run `tools/release.sh X.Y.Z` (use `--dry-run` first if unsure). It checks,
   builds the zip, tags, creates the GitHub release, uploads the version to
   Modrinth (`tools/modrinth.json`), and syncs the Modrinth page from
   README.md.

## Privacy

- The only identity in this repo is `HandLock_` with
  `54068030+Hand-Lock@users.noreply.github.com`. Check `git config user.email`
  before the first commit.
- Never commit emails, real names, local paths (`/Users/…`), or tokens.
  `tools/check.sh` greps for them.
- The Modrinth token lives in the macOS Keychain (service `modrinth-token`)
  or `$MODRINTH_TOKEN`; never write it to a file.

## References

- Iris/OptiFine shader properties: https://shaders.properties
- OptiFine `shaders.txt` (programs, fallbacks, uniforms):
  https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt
- Modrinth API v2: https://docs.modrinth.com/api/
