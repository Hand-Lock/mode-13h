// /shaders/lib/fog.glsl — Vanilla-compatible fog (GL 4.1, Iris/Oculus)
// Supports spherical and cylindrical distance, linear/exp/exp2 curves,
// and optional parameter tuning. Exposes viewPosFromFrag() for affine.glsl.

#ifndef FOG_GLSL
#define FOG_GLSL

uniform vec3  fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform int   fogMode;   // GL_LINEAR=9729, GL_EXP=2048, GL_EXP2=2049
uniform int   fogShape;  // 0 = sphere, 1 = cylinder

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform float viewWidth;
uniform float viewHeight;

const int GL_LINEAR = 9729;
const int GL_EXP    = 2048;
const int GL_EXP2   = 2049;

// Reconstruct view-space position from fragment depth.
vec3 viewPosFromFrag() {
    vec2 uv  = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float d  = gl_FragCoord.z;
    vec4 ndc = vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0);
    vec4 v   = gbufferProjectionInverse * ndc;
    return v.xyz / v.w;
}

// Fog distance: spherical (view-space length) or cylindrical (horizontal world-space).
float fogDistanceFromViewPos(vec3 vpos) {
    if (fogShape == 1) {
        vec3 vWorld = (gbufferModelViewInverse * vec4(vpos, 0.0)).xyz;
        return length(vWorld.xz);
    } else {
        return length(vpos);
    }
}

// Optional numeric tuning of fog parameters (does not change fog mode).
void tuneFogParams(inout float start, inout float end_, inout float dens) {
#if (FOG_TUNE_ENABLE == 1)
    start = start * float(FOG_START_SCALE) + float(FOG_START_ADD);
    end_  = end_  * float(FOG_END_SCALE)   + float(FOG_END_ADD);
    dens  = max(dens * float(FOG_DENSITY_SCALE), 0.0);

    // Prevent degenerate linear fog when start >= end
    float minRange = max(float(FOG_MIN_RANGE), 1e-6);
    if (fogMode == GL_LINEAR) {
        float range = end_ - start;
        if (range < minRange) {
            float mid = 0.5 * (start + end_);
            start = mid - 0.5 * minRange;
            end_  = mid + 0.5 * minRange;
        }
    }
#endif
}

// Vanilla fog curve evaluation.
float vanillaFogFactor(float d) {
    float start = fogStart;
    float end_  = fogEnd;
    float dens  = fogDensity;
    tuneFogParams(start, end_, dens);

    if (fogMode == GL_LINEAR) {
        return clamp((d - start) / max(end_ - start, 1e-6), 0.0, 1.0);
    } else if (fogMode == GL_EXP) {
        return clamp(1.0 - exp(-dens * d), 0.0, 1.0);
    } else if (fogMode == GL_EXP2) {
        float t = dens * d;
        return clamp(1.0 - exp(-t * t), 0.0, 1.0);
    } else {
        // Fallback: linear
        return clamp((d - start) / max(end_ - start, 1e-6), 0.0, 1.0);
    }
}

// Apply fog to a fragment color.
vec3 applyFog(vec3 rgb) {
    vec3  vpos = viewPosFromFrag();
    float d    = fogDistanceFromViewPos(vpos);
    float f    = vanillaFogFactor(d);
    return mix(rgb, fogColor, f);
}

#endif
