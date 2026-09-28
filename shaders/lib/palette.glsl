// Color reduction helpers (GL 4.1)

#ifndef PALETTE_GLSL
#define PALETTE_GLSL

// 216 colors: uniform 6x6x6 RGB cube.
vec3 quantizeCube6(vec3 c) {
    return floor(clamp(c, 0.0, 1.0) * 5.0 + 0.5) / 5.0;
}

// 256 colors: RGB332 (8 levels R, 8 levels G, 4 levels B).
// Quantization in sqrt-space preserves midtone detail.
vec3 quantize256(vec3 c) {
    const vec3 levels = vec3(7.0, 7.0, 3.0);
    vec3 q = floor(sqrt(clamp(c, 0.0, 1.0)) * levels + 0.5) / levels;
    return q * q;
}

#endif
