// /shaders/lib/affine.glsl — Affine texture mapping helper (GL 4.1)
// Requires viewPosFromFrag() from fog.glsl, which must be included first.

#ifndef AFFINE_GLSL
#define AFFINE_GLSL

vec2 affineUV(in vec2 uv_persp, in vec2 uv_affine) {
#if (DOS_AFFINE_ENABLE == 1)
    float nearD = float(DOS_AFFINE_NEAR);
    float range = max(float(DOS_AFFINE_RANGE), 1e-6);

    vec3 vpos  = viewPosFromFrag();
    float dist = max(-vpos.z, 0.0);

    float t = clamp((dist - nearD) / range, 0.0, 1.0);
    return mix(uv_persp, uv_affine, t);
#else
    return uv_persp;
#endif
}

#endif
