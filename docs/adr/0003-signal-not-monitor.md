# 0003. Emulate the signal, not the monitor

Date: 2026-09-28
Status: Accepted

## Context

Retro packs often add CRT curvature, scanlines, bloom and aspect stretching.
A Mode 13h game didn't produce any of that; the monitor did, and players
remember the pixels more than the glass. Rendering at 320×200 directly would
also break the GUI and needs resolution control that shaderpacks don't have.

## Decision

- gbuffers passes render at full window resolution.
- `final` takes one point sample per `DOS_SCALE`×`DOS_SCALE` cell and
  quantizes it to the palette. 1280×800 at scale 4 gives exactly 320×200.
- No CRT, scanline, bloom or non-square-pixel emulation. The player stretches
  the window to 4:3.

## Consequences

- One cheap full-screen pass does the whole "signal" step.
- Point sampling picks the cell's top-left texel, so sub-cell detail
  (thin geometry, distant textures) can flicker; R4 in SPEC.md addresses
  texture shimmer.
- The GUI draws after `final` and stays native and unpalettized.
