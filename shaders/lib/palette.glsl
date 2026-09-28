// Color reduction to the selected palette (DOS_PALETTE). ADR 0010.

#ifndef PALETTE_GLSL
#define PALETTE_GLSL

// 32x32x64 nearest-entry LUT from tools/palette.sh: z 0-31 ramp, 32-63 VGA.
uniform sampler3D paletteLut;

vec3 palettize(vec3 c) {
    c = clamp(c, 0.0, 1.0);
#if (DOS_PALETTE == 1 || DOS_PALETTE == 2)
    ivec3 i = ivec3(c * 31.0 + 0.5);
    return texelFetch(paletteLut, i + ivec3(0, 0, 32 * (DOS_PALETTE - 1)), 0).rgb;
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
