# 0013. Historical palettes

Date: 2026-09-28
Status: Accepted. Amends ADR 0010.

## Context

ADR 0010 ships two LUT palettes, ramp and stock VGA. Players asked for the
palettes of the DOS games the pack imitates, so Minecraft can take on the
colors of Doom, Quake or Daggerfall.

## Decision

- Only 256-color palettes, since that is Mode 13h. CGA and EGA are out. One
  palette per game: the one its 3D world is drawn with.

  | Value | Palette           | Source                                       |
  |-------|-------------------|----------------------------------------------|
  | 5     | Mac OS system (1987) | computed: 6×6×6 cube at 0x33 steps without black, 10-step R, G, B and gray ramps, black, in Apple's index order |
  | 6     | Wolfenstein 3D (1992) | SLADE `Wolfenstein 3D .pal`              |
  | 7     | Doom (1993)       | SLADE `Doom .pal`, PLAYPAL palette 0         |
  | 8     | Heretic (1994)    | SLADE `Heretic .pal`, palette 0              |
  | 9     | Hexen (1995)      | SLADE `Hexen .pal`, palette 0                |
  | 10    | Quake (1996)      | SLADE `Quake .pal`                           |
  | 11    | Duke Nukem 3D (1996) | SLADE `Duke Nukem .pal`                   |
  | 12    | Daggerfall (1996) | `ART_PAL.COL`, from UESP's lossless swatch PNG |

  SLADE's palettes are in its GPL repository, under `dist/res/palettes/`.
  Each text file in `tools/palettes/` says in its header where its data
  came from and how it was converted. The one-off conversion snippets are
  not committed.
- 8-bit values become 6-bit with `v >> 2`, which is what the DOS engines did
  when they wrote the DAC. Wolfenstein 3D's data is its original 6-bit values
  ×4, so this conversion is exact.
- Transparency keys the engine never draws become black, so the
  nearest-color search can't pick a color the game never showed. That is
  Quake 255 and Duke Nukem 3D 255. Daggerfall's key, entry 0, is already
  black. No other entry is changed.
- Values 0–4 keep their meaning and the new palettes are appended, so saved
  settings still work. 3 and 4 stay computed, so LUT slots skip them:
  slot = value − 1 for 1–2, value − 3 for 5 and up.
- All palettes stay in the one raw 3D texture, which grows to 10 slots:
  32×32×320, 1.25 MB (75 KB gzipped). GL 4.1 guarantees a 3D texture depth
  of at least 2048. Loading only the selected palette through `#if` in
  `shaders.properties` would be smaller, but it would add untested
  Iris/Oculus behavior on top of the raw 3D texture, which ADR 0010 already
  flags as the risky part.

## Consequences

- Adding a palette is a text file, one name in `tools/palette.sh`'s loop, a
  new option value, and a size bump in `shaders.properties`,
  `lib/palette.glsl`'s comment and `tools/check.sh`.
- The pack zip grows by about 60 KB.
- Colormap lighting uses the selected palette's own ramps. Game palettes have
  fewer ramps in Minecraft's hues than the ramp palette, so some blocks shift
  color more.
