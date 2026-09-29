# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions: [SemVer](https://semver.org/) (see `docs/adr/0008-release-and-privacy.md`).

## [Unreleased]

### Added
- Billy Boarding: potted cactus.
- Billy Boarding: wall bells and pitcher crops.

### Fixed
- Billy Boarding no longer mangles candles and sea pickles, which it has no
  models for yet.
- Billy Boarding potted plants no longer z-fight.
- Billy Boarding: cakes, candle cakes, anvils and bells no longer show black
  where their sprites are transparent.

## [2.1.0] - 2026-09-29

### Added
- Palettes from Wolfenstein 3D, Doom, Heretic, Hexen, Quake, Duke Nukem 3D
  and Daggerfall, and the Mac OS system palette.

## [2.0.0] - 2026-09-28

### Added
- A fixed 256-color palette, now the default: 16 Minecraft hues in 16 shades
  each, like a DOS game's own palette.
- The stock VGA palette, as an option.
- Colormap lighting (default on): textures use only palette colors and
  shading steps down each color's ramp, like Doom and Quake.

### Changed
- Texture mapping defaults to Quake-style subdivision: perspective-correct
  every 16 pixels and linear in between, a subtle wobble instead of heavy
  warping. Full affine and perspective-correct are options (Texture Mapping).
- Textures pick their mipmap for the 320×200 output, so distant surfaces
  shimmer much less.
- Rain and particles use the generic textured program; rain now wobbles like
  other geometry.
- Fog and texture mapping take the pixel position from the vertex shader
  instead of reconstructing it per pixel. Same look, less work.
- Viewmodel Dithering is now a strength slider; 0 turns it off.
- The option menu is trimmed (see Removed). Saved settings for removed or
  renamed options reset to their defaults.

### Fixed
- Surfaces seen at a very steep angle no longer smear, or show other blocks'
  textures inside them or as lines along their edges, with subdivided
  mapping.
- 1.21.x flora (bush, eyeblossoms, dry grass…) billboards again; it broke in 1.0.3.
- Copper Age chains and lanterns now actually billboard.
- Stained glass, ice and other translucents no longer darken at night; only water does.

### Removed
- Palette Mode and Bypass options, replaced by Palette (Off, Ramp, VGA,
  RGB332, 6x6x6).
- Affine Mapping, Near Distance and Fade Range options (replaced by Texture
  Mapping).
- Fog Tuning toggle, Start/End Offset and Minimum Range options. Fog keeps
  its Start, End and Density scales; 1.00 is vanilla.
- Dither Strength option (merged into Viewmodel Dithering).
- OptiFine from the listed loaders. It was never supported.
- Programs that duplicated their Iris fallback, and an unused one. No visual change.

## [1.0.3] - 2026-04-07

### Added
- New Copper Age blocks to the billboarding list.

## [1.0.2] - 2026-03-27

### Added
- Hand options for dithering and no shading.

### Changed
- Slightly changed default fog options.

## [1.0.1] - 2026-03-22

### Added
- Billboarding for blocks from newer versions.

### Fixed
- A small kelp issue.

## [1.0.0] - 2026-03-15

- Initial release, tested on Minecraft 1.20.1 with Iris and Oculus.
