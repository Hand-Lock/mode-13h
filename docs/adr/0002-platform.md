# 0002. Platform: Iris/Oculus, GLSL 4.10 compatibility, 1.20.1 + 1.21.1

Date: 2026-09-28
Status: Accepted (amended by ADR 0019)

## Context

The author and part of the audience play on macOS, where OpenGL stops at 4.1.
Modpacks cluster on two long-lived versions: 1.20.1 (Forge/Oculus) and 1.21.1
(NeoForge/Fabric). Newer versions change block names and rendering details
often. OptiFine was listed on Modrinth but never tested.

## Decision

- Every program uses `#version 410 compatibility`. No GL ≥ 4.2 features.
- Target Iris and Oculus only. The Modrinth loader tag is `iris` only.
- 1.20.1 and 1.21.1 are mandatory and tested in-game before each release.
  Later versions are best-effort and listed on Modrinth only once they load.

## Consequences

- The compatibility profile keeps `ftransform()`, `gl_Color` and friends, which
  keeps the vertex shaders short.
- Features that need newer GL (compute, SSBO, image store) are ruled out;
  anything stateful has to be done with render targets.
- `block.properties` keeps old and new block names side by side.
