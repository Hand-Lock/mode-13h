// Vanilla-compatible fog: spherical or cylindrical distance, linear/exp/exp2
// curves, optional parameter tuning.

#ifndef FOG_GLSL
#define FOG_GLSL

uniform vec3  fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform int   fogMode;   // GL_LINEAR=9729, GL_EXP=2048, GL_EXP2=2049
uniform int   fogShape;  // 0 = sphere, 1 = cylinder

uniform mat4 gbufferModelViewInverse;

const int GL_LINEAR = 9729;
const int GL_EXP    = 2048;
const int GL_EXP2   = 2049;

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

// Vanilla fog curve; anything but EXP/EXP2 is linear.
float fogFactor(float d) {
    float start = fogStart;
    float end_  = fogEnd;
    float dens  = fogDensity;
    tuneFogParams(start, end_, dens);

    if (fogMode == GL_EXP) {
        return clamp(1.0 - exp(-dens * d), 0.0, 1.0);
    } else if (fogMode == GL_EXP2) {
        float t = dens * d;
        return clamp(1.0 - exp(-t * t), 0.0, 1.0);
    }
    return clamp((d - start) / max(end_ - start, 1e-6), 0.0, 1.0);
}

vec3 applyFog(vec3 rgb, vec3 viewPos) {
    float d = fogShape == 1
        ? length((mat3(gbufferModelViewInverse) * viewPos).xz)
        : length(viewPos);
    return mix(rgb, fogColor, fogFactor(d));
}

#endif
