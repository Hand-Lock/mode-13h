# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions: [SemVer](https://semver.org/) (see `docs/adr/0008-release-and-privacy.md`).

## [Unreleased]

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

### Fixed
- 1.21.x flora (bush, eyeblossoms, dry grass…) billboards again; it broke in 1.0.3.
- Copper Age chains and lanterns now actually billboard.
- Stained glass, ice and other translucents no longer darken at night; only water does.

### Removed
- Affine Mapping, Near Distance and Fade Range options (replaced by Texture
  Mapping).
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
