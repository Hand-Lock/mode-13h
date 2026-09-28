#!/bin/sh
# Publish a release: check, build, tag, GitHub release, Modrinth version,
# Modrinth page body (from README.md).
# Usage: tools/release.sh X.Y.Z [--dry-run]
#   --dry-run  run checks and build, print every payload, send nothing.
# Token: $MODRINTH_TOKEN, else Keychain item "modrinth-token".
set -eu

cd "$(dirname "$0")/.."
die() { echo "release: $*" >&2; exit 1; }
warn() { echo "release: warning: $*" >&2; }

ver=${1:-}
dry=0
[ "${2:-}" = --dry-run ] && dry=1
printf '%s' "$ver" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || die "usage: tools/release.sh X.Y.Z [--dry-run]"
tag=v$ver
API=https://api.modrinth.com/v2
UA="Hand-Lock/mode-13h release.sh (github.com/Hand-Lock/mode-13h)"
CFG=tools/modrinth.json
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# In a dry run, precondition failures are warnings.
need() { if [ "$dry" = 1 ]; then warn "$*"; else die "$*"; fi; }

# --- preconditions ----------------------------------------------------------
[ "$(git rev-parse --abbrev-ref HEAD)" = main ] || need "not on main"
[ -z "$(git status --porcelain)" ] || need "working tree not clean"
git fetch -q origin main
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || need "HEAD is not origin/main (push first)"
! git rev-parse -q --verify "refs/tags/$tag" >/dev/null || need "tag $tag already exists"

# Changelog section for this version (dry run falls back to [Unreleased]).
section() {
    awk -v h="## [$1]" '
        index($0, h) == 1 { on = 1; next }
        on && /^## \[/    { exit }
        on                { print }' CHANGELOG.md | sed -e '/./,$!d' | sed -e ':a' -e '/^\n*$/{$d;N;ba' -e '}'
}
notes=$(section "$ver")
if [ -z "$notes" ]; then
    need "no '## [$ver]' section in CHANGELOG.md"
    notes=$(section Unreleased)
fi
printf '%s\n' "$notes" > "$TMP/notes.md"

# Modrinth style: "### Fixed" + "- text" -> "- **Fixed:** text".
{
    printf '**Changelog – Version %s**\n\n' "$ver"
    awk '/^### / { kind = substr($0, 5); next }
         /^- /   { if (kind != "") print "- **" kind ":** " substr($0, 3); else print; next }
         /^$/    { next }
                 { print }' "$TMP/notes.md"
    printf '\n— HandLock_\n'
} > "$TMP/changelog.md"

if [ "$dry" = 0 ]; then
    token=${MODRINTH_TOKEN:-$(security find-generic-password -s modrinth-token -w 2>/dev/null || true)}
    [ -n "$token" ] || die "no Modrinth token (set MODRINTH_TOKEN or add Keychain item modrinth-token)"
    gh auth status >/dev/null 2>&1 || die "gh is not authenticated"
fi

# --- check and build --------------------------------------------------------
tools/check.sh
zip=$(tools/build.sh "$ver")
file=$(basename "$zip")

jq --arg v "$ver" --rawfile cl "$TMP/changelog.md" '{
    project_id, loaders, game_versions, version_type,
    name: $v, version_number: $v, changelog: $cl,
    dependencies: [], featured: true, status: "listed",
    file_parts: ["file"], primary_file: "file"
}' "$CFG" > "$TMP/version.json"
project=$(jq -r .project_id "$CFG")
jq -n --rawfile b README.md '{body: $b}' > "$TMP/body.json"

if [ "$dry" = 1 ]; then
    echo "--- git: tag $tag, push origin $tag"
    echo "--- gh release create $tag $zip --title $ver, notes:"
    cat "$TMP/notes.md"
    echo "--- POST $API/version (file: $file)"
    cat "$TMP/version.json"
    echo "--- PATCH $API/project/$project body: README.md ($(wc -c < README.md | tr -d ' ') bytes)"
    echo "--- dry run: nothing sent"
    exit 0
fi

# --- publish ----------------------------------------------------------------
git tag "$tag"
git push origin "$tag"

gh release create "$tag" "$zip" --title "$ver" --notes-file "$TMP/notes.md"

curl -sS --fail-with-body -X POST "$API/version" \
    -H "Authorization: $token" -H "User-Agent: $UA" \
    -F "data=<$TMP/version.json;type=application/json" \
    -F "file=@$zip;type=application/zip;filename=$file" > "$TMP/resp.json" ||
    { cat "$TMP/resp.json" >&2; die "Modrinth version upload failed (tag and GitHub release already exist)"; }
echo "Modrinth version: $(jq -r .id "$TMP/resp.json")"

curl -sS --fail-with-body -X PATCH "$API/project/$project" \
    -H "Authorization: $token" -H "User-Agent: $UA" \
    -H "Content-Type: application/json" --data-binary "@$TMP/body.json" ||
    die "Modrinth page body update failed"

echo "released $ver"
