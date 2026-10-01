# 0022. Golden Days flat candles

Date: 2026-10-01
Status: Accepted

## Context

Golden Days (GD) 16.4 has a "Flat Candles" option. It is Polytone-only (a
`polytone_condition` overlay) and replaces
`block/template_{candle,two_candles,three_candles,four_candles}[_lit]`.
In those models each candle is its own 45° cross with `rescale`: two
2 px-wide vertical planes, UV `[7, v0, 9, 15]`, rotated around that
candle's own origin:

| model | candle centers (px), height |
|---|---|
| one | (8,8) 7 |
| two | (10,7) 7 · (6,8) 6 |
| three | (9,7) 7 · (6,8) 6 · (8,10) 5 |
| four | (9,6) 7 · (6,6) 6 · (10,9) 6 · (7,9) 4 |

Turning the whole block around its center, as the Billy Boarding path
(10990) does, would swing the candles around the block and pull them away
from their flame particles.

## Decision

- Candles get their own ID, 10991, remapped to the flora cross path
  (10950) at the top of `gbuffers_terrain.vsh` when the off-by-default
  `GOLDEN_DAYS_CANDLES` option is on.
- The cross path already fits: `crossFace()` takes each face's center from
  its own vertices and its UV offset from `mc_midTexCoord`, never the block
  center. Each candle keeps its (+x,+z) face and turns around its own axis,
  so the wick stays where the vanilla flame spawns.
- The depth buffer is enough: the closest pair of candles is 2.83 px apart,
  so two billboards only overlap on screen when one is at least 2 px
  deeper. No layer ranks.
- 10991 sits in the add-on range but outside the `noAffine` range
  (`id < 10990`): with the toggle off it matches no branch and vanilla
  candles render as before.
- A separate toggle from `GOLDEN_DAYS`: the flat candles are a Polytone
  option that many GD players won't have on, and the toggle must match it.
- Candle cakes stay Billy Boarding's (10990).

## Consequences

- Amends ADR 0021: flat candles are the one supported GD Polytone option.
- `crossFace()` assumes vanilla's 0.9 block per texel ratio; GD candles are
  1:1, so each center lands 0.1 px off along the face. Not visible, not
  corrected.
- With the toggle on but without GD's flat candles, the side faces of
  vanilla candle boxes are culled. Same contract as the other add-on
  toggles.
