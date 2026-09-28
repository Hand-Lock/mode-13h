// Color reduction to the selected palette (DOS_PALETTE). ADR 0010.

#ifndef PALETTE_GLSL
#define PALETTE_GLSL

// 32x32x320 nearest-entry LUT from tools/palette.sh: 10 palettes stacked on z,
// 32 slices each, in the order of the loop there.
uniform sampler3D paletteLut;

vec3 palettize(vec3 c) {
    c = clamp(c, 0.0, 1.0);
#if (DOS_PALETTE == 1 || DOS_PALETTE == 2 || DOS_PALETTE >= 5)
    // 3 and 4 are computed below and have no LUT slot.
    const int slot = DOS_PALETTE < 3 ? DOS_PALETTE - 1 : DOS_PALETTE - 3;
    ivec3 i = ivec3(c * 31.0 + 0.5);
    return texelFetch(paletteLut, i + ivec3(0, 0, 32 * slot), 0).rgb;
#elif (DOS_PALETTE == 3)
    // RGB332 (8 levels R, 8 G, 4 B) in sqrt space to keep midtone detail.
    const vec3 levels = vec3(7.0, 7.0, 3.0);
    vec3 q = floor(sqrt(c) * levels + 0.5) / levels;
    return q * q;
#elif (DOS_PALETTE == 4)
    // 6x6x6 cube, 216 colors.
    return floor(c * 5.0 + 0.5) / 5.0;
#else
    return c;
#endif
}

#endif
