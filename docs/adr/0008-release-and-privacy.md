# 0008. Release, versioning and privacy

Date: 2026-09-28
Status: Accepted

## Context

Releases were zipped by hand in Finder (which added `__MACOSX/` and
`.DS_Store`) and uploaded by hand. Early commits exposed a personal email.

## Decision

- SemVer tags `vX.Y.Z` on `main`. Patch = fixes and block additions, minor =
  features or visible look changes, major = removed/renamed options or add-on
  ID changes.
- `CHANGELOG.md` in Keep a Changelog format; the release notes come from it.
- `tools/release.sh` does everything: check, build from `git archive`, tag,
  GitHub release, Modrinth version (`tools/modrinth.json`, loader `iris`
  only), and sync the Modrinth page body from README.md.
- Releases happen only when the user says "release".
- The only committed identity is `HandLock_` with the GitHub noreply email.
  The Modrinth token lives in the macOS Keychain (`modrinth-token`) or
  `$MODRINTH_TOKEN`, never in a file. `tools/check.sh` greps for emails and
  local paths.

## Consequences

- Zips contain only `shaders/` and `LICENSE`.
- The Modrinth page can't drift from README.md; edit README, not the site.
- History was rewritten once to remove the old email; old SHAs may still be
  cached by GitHub or forks.
