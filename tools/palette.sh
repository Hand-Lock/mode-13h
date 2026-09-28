#!/bin/sh
# Build shaders/textures/palette.dat, the palette lookup texture: for each
# input color on a 32x32x32 grid, the nearest entry (in OKLab) of each palette
# in tools/palettes/. Raw RGBA8, x = red, y = green, z = blue; z 0-31 is
# ramp.txt, z 32-63 is vga.txt. Deterministic: ties go to the lower index.
# Usage: tools/palette.sh
set -eu

cd "$(dirname "$0")/.."
out=shaders/textures/palette.dat
mkdir -p shaders/textures

lut='
function lin(v) { return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4 }
function cbrt(x) { return x > 0 ? exp(log(x) / 3) : 0 }
# Sets L, A, B from sRGB in 0..1.
function oklab(r, g, b,   l, m, s) {
    r = lin(r); g = lin(g); b = lin(b)
    l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
    m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
    s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
}
BEGIN { n = 0 }
/^[ \t]*(#|$)/ { next }
{
    if (NF != 3 || $1 !~ /^[0-9]+$/ || $2 !~ /^[0-9]+$/ || $3 !~ /^[0-9]+$/ || $1 > 63 || $2 > 63 || $3 > 63) {
        printf "%s:%d: expected \"r g b\" in 0..63\n", FILENAME, FNR > "/dev/stderr"; bad = 1; exit 1
    }
    oklab($1 / 63, $2 / 63, $3 / 63)
    pl[n] = L; pa[n] = A; pb[n] = B
    hex[n] = sprintf("%02x%02x%02xff", int($1 * 255 / 63 + 0.5), int($2 * 255 / 63 + 0.5), int($3 * 255 / 63 + 0.5))
    n++
}
END {
    if (bad) exit 1
    if (n != 256) { printf "%s: %d entries, need 256\n", FILENAME, n > "/dev/stderr"; exit 1 }
    for (b = 0; b < 32; b++) for (g = 0; g < 32; g++) {
        line = ""
        for (r = 0; r < 32; r++) {
            oklab(r / 31, g / 31, b / 31)
            best = 0; bd = 1e9
            for (i = 0; i < 256; i++) {
                dl = L - pl[i]; da = A - pa[i]; db = B - pb[i]
                d = dl * dl + da * da + db * db
                if (d < bd) { bd = d; best = i }
            }
            line = line hex[best]
        }
        print line
    }
}'

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
for p in ramp vga; do
    awk "$lut" "tools/palettes/$p.txt" >> "$tmp"
done
xxd -r -p "$tmp" > "$out"
echo "$out"
