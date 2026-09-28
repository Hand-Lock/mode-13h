# 0012. Option overhaul for 2.0.0

Date: 2026-09-28
Status: Accepted

## Context

The 1.x menu grew one option per knob: separate enable toggles in front of
the values they gated, additive fog offsets next to the multipliers, and a
dither on/off beside its strength. ADRs 0006, 0007, 0010 and 0011 also
replaced the palette and affine mapping, so their old options no longer
describe what the pack does.

## Decision

The menu keeps only options a player would reach for. Main screen: Pixel
Scale, Palette, Colormap Lighting, Light Steps, Ambient Floor. Sub-screens:
Texture Mapping, Fog, Hands, Add-ons.

| 1.x option                              | 2.0.0                                   |
|-----------------------------------------|-----------------------------------------|
| `DOS_PALETTE_256`, `DOS_PALETTE_BYPASS` | `DOS_PALETTE` (0 = off)                 |
| —                                       | `DOS_COLORMAP` (new)                    |
| `DOS_AFFINE_ENABLE`, `_NEAR`, `_RANGE`  | `DOS_TEXMAP`, `DOS_SPAN`                |
| `FOG_TUNE_ENABLE`                       | removed; all scales at 1.00 is vanilla  |
| `FOG_START_ADD`, `FOG_END_ADD`          | removed                                 |
| `FOG_MIN_RANGE`                         | removed; fixed at 1 block               |
| `HAND_DITHER`, `HAND_DITHER_STRENGTH`   | `HAND_DITHER` is the strength (0 = off) |

Removing and renaming options is a breaking change, so this ships as 2.0.0
(ADR 0008).

## Consequences

- Saved settings for removed or renamed options reset to the new defaults. A
  saved `HAND_DITHER=1` is no longer a listed value and may reset too.
- Fog can only be scaled, not offset. The defaults (start ×0.50) keep the 1.x
  look.
