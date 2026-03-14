// /shaders/lib/palette.glsl — Color reduction helpers (GL 4.1)

#ifndef PALETTE_GLSL
#define PALETTE_GLSL

// 216 colors: uniform 6x6x6 RGB cube.
vec3 quantizeCube6(vec3 c) {
    ivec3 q = clamp(ivec3(floor(c * 5.0 + 0.5)), ivec3(0), ivec3(5));
    return vec3(q) / 5.0;
}

// 256 colors: RGB332 (8 levels R, 8 levels G, 4 levels B).
// Quantization in sqrt-space preserves midtone detail.
vec3 quantize256(vec3 c) {
    c = clamp(c, 0.0, 1.0);
    vec3 p = sqrt(c);

    float r = floor(p.r * 7.0 + 0.5) / 7.0;
    float g = floor(p.g * 7.0 + 0.5) / 7.0;
    float b = floor(p.b * 3.0 + 0.5) / 3.0;

    vec3 q = vec3(r, g, b);
    return q * q;
}

#endif
