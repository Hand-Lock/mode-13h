#!/bin/sh
# Offline checks: compile every program with glslang, lint config files,
# scan for private data. Exits non-zero on any failure.
# Usage: tools/check.sh
set -u

cd "$(dirname "$0")/.." || exit 1
S=shaders
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
fail=0
err() { printf 'FAIL %s\n' "$*"; fail=1; }

command -v glslangValidator >/dev/null || { echo "glslangValidator missing: brew install glslang"; exit 1; }

# Inline Iris-style `#include "/path"` (relative to shaders/), each file once.
inline() {
    awk -v root="$S" '
    function emit(f,   line, inc) {
        if (f in seen) return
        seen[f] = 1
        while ((getline line < f) > 0) {
            if (line ~ /^[ \t]*#include[ \t]+"/) {
                inc = line
                sub(/^[^"]*"/, "", inc); sub(/".*$/, "", inc)
                if ((getline tmp < (root inc)) < 0) { print "missing include " inc > "/dev/stderr"; exit 2 }
                close(root inc)
                emit(root inc)
            } else print line
        }
        close(f)
    }
    { } END { emit(ARGV[1]) }' "$1" </dev/null
}

# Stubs for what Iris injects at load time, after the #version line.
STUBS='#define MC_VERSION 12001
#define IS_IRIS
#define MC_GL_VERSION 410
#define MC_GLSL_VERSION 410'

# compile FILE LABEL: compile an inlined program; the stage comes from LABEL.
compile() {
    case $2 in *.vsh*) stage=vert ;; *) stage=frag ;; esac
    if ! log=$(glslangValidator -S "$stage" "$1" 2>&1); then
        echo "FAIL $2"
        # Line numbers refer to the inlined source; show that line.
        printf '%s\n' "$log" | grep '^ERROR: 0:' | while IFS= read -r l; do
            n=$(printf '%s' "$l" | sed 's/^ERROR: 0:\([0-9]*\):.*/\1/')
            printf '    %s\n      > %s\n' "$l" "$(sed -n "${n}p" "$1" | sed 's/^[ \t]*//')"
        done
    fi
}

mkdir "$TMP/src"
progs=$(cd "$S" && ls *.vsh *.fsh)
for p in $progs; do
    src=$TMP/src/$p
    body=$(inline "$S/$p") || { err "$p: include failed"; continue; }
    {
        printf '%s\n' "$body" | sed -n '1p'
        printf '%s\n' "$STUBS"
        printf '%s\n' "$body" | sed '1d'
    } > "$src"
    compile "$src" "$p"
done | grep . && fail=1

# Branch pass: recompile each program that mentions an option with every other
# value of it (sliders: only their extremes).
sliders=$(sed -n '/^sliders/,/[^\\]$/p' "$S/shaders.properties")
sed -n 's/^#define \([A-Z0-9_]*\) *\([^ ]*\) *\/\/ *\[\(.*\)\].*/\1 \2 \3/p' "$S/shaders.settings" |
while read -r opt def vals; do
    if printf '%s\n' "$sliders" | grep -qw "$opt"; then
        set -- $vals; first=$1; shift $(($# - 1)); vals="$first $1"
    fi
    for v in $vals; do
        [ "$v" = "$def" ] && continue
        for p in $progs; do
            grep -w "$opt" "$TMP/src/$p" 2>/dev/null | grep -qv '^#define' || continue
            sed "s/^#define $opt .*/#define $opt $v/" "$TMP/src/$p" > "$TMP/variant"
            compile "$TMP/variant" "$p with $opt=$v"
        done
    done
done | grep . && fail=1

# Palette LUT: 32x32x64 RGBA8 from tools/palette.sh.
lut=$S/textures/palette.dat
[ "$(wc -c < "$lut" 2>/dev/null | tr -d ' ')" = 262144 ] ||
    err "$lut: missing or not 262144 bytes (run tools/palette.sh)"

# block.properties: comments inside continuations and whitespace after `\`
# silently drop the blocks that follow.
awk '
    prev_cont && /^[ \t]*#/ { printf "FAIL block.properties:%d: comment inside continuation\n", NR; bad=1 }
    /\\[ \t]+$/             { printf "FAIL block.properties:%d: whitespace after backslash\n", NR; bad=1 }
    { prev_cont = ($0 ~ /\\$/) && ($0 !~ /^[ \t]*#/) }
    END { exit bad }' "$S/block.properties" || fail=1

# Every menu option (a define with `// [values]`) needs a lang entry and a screen slot.
screens=$(sed -n '/^screen/,/^[^ ]/p' "$S/shaders.properties" | grep -v '^sliders')
for opt in $(sed -n 's/^#define \([A-Z0-9_]*\) .*\/\/ *\[.*/\1/p' "$S/shaders.settings"); do
    grep -q "^option\.$opt=" "$S/lang/en_us.lang" || err "$opt: no option.$opt in lang/en_us.lang"
    printf '%s\n' "$screens" | grep -qw "$opt" || err "$opt: not in any screen in shaders.properties"
done

# Private data: emails other than GitHub noreply, local home paths.
priv=$(git ls-files -co --exclude-standard | grep -v '^tools/check\.sh$' | while IFS= read -r f; do
    [ -f "$f" ] || continue
    grep -HnoIE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|/Users/[A-Za-z0-9._-]+|/home/[a-z][A-Za-z0-9._-]*' "$f"
done | grep -vE ':[0-9]+:([^:]*@users\.noreply\.github\.com|noreply@anthropic\.com)$')
[ -n "$priv" ] && { err "private data:"; printf '%s\n' "$priv" | sed 's/^/    /'; }

[ "$fail" = 0 ] && echo "check: ok"
exit "$fail"
