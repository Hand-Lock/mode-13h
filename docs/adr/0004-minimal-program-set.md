# 0004. Minimal program set through the Iris fallback chain

Date: 2026-09-28
Status: Accepted

## Context

Early versions copied the same shader into several programs
(`textured_lit`, `entities_glowing`, `hand_water`) and kept a
`gbuffers_translucent` that Iris never runs. Copies drift and hide bugs: the
water-only night tweak lived in the dead file while the live one applied to
all translucents.

## Decision

Only write a program when it must behave differently from its fallback.
Everything else is left to Iris's fallback chain (listed in AGENTS.md). No
composite or deferred passes until a feature needs one.

## Consequences

- Fewer files to keep in sync; a fix in `textured` reaches every program that
  falls back to it.
- Program-specific behavior needs its own file even if the difference is
  small; the reviewer checks that it's really different.
