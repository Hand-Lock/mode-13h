# 0001. Record architecture decisions

Date: 2026-09-28
Status: Accepted

## Context

Mode 13h is developed largely by AI agents in short sessions. Without a record,
each session re-derives or silently reverses earlier choices.

## Decision

Record decisions in `docs/adr/NNNN-slug.md` using a short Nygard format:
Status, Context, Decision, Consequences. Write one when a change decides
something about architecture, the look, compatibility, or distribution.
Bug fixes, block-list additions and option tweaks don't need one.

Statuses: Proposed, Accepted, Accepted — not yet implemented, Superseded by
NNNN. Don't rewrite an accepted ADR's decision; supersede it with a new one.

## Consequences

Agents read `docs/adr/` before architectural work (AGENTS.md says so).
Reasons survive after the conversation that produced them is gone.
