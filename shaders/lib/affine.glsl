// Affine texture mapping helper.

#ifndef AFFINE_GLSL
#define AFFINE_GLSL

vec2 affineUV(vec2 uv_persp, vec2 uv_affine, vec3 viewPos) {
#if (DOS_AFFINE_ENABLE == 1)
    float nearD = float(DOS_AFFINE_NEAR);
    float range = max(float(DOS_AFFINE_RANGE), 1e-6);
    float t = clamp((max(-viewPos.z, 0.0) - nearD) / range, 0.0, 1.0);
    return mix(uv_persp, uv_affine, t);
#else
    return uv_persp;
#endif
}

#endif
