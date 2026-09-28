// Vanilla-compatible fog: spherical or cylindrical distance, linear/exp/exp2
// curves, scaled distances.

#ifndef FOG_GLSL
#define FOG_GLSL

uniform vec3  fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform int   fogMode;   // GL_LINEAR, GL_EXP or GL_EXP2
uniform int   fogShape;  // 0 = sphere, 1 = cylinder

uniform mat4 gbufferModelViewInverse;

const int GL_EXP    = 2048;
const int GL_EXP2   = 2049;

// Vanilla fog curve with start, end and density scaled by the FOG_* options
// (1.00 = vanilla). Anything but EXP/EXP2 is linear.
float fogFactor(float d) {
    if (fogMode == GL_EXP || fogMode == GL_EXP2) {
        float t = fogDensity * float(FOG_DENSITY_SCALE) * d;
        return clamp(1.0 - exp(fogMode == GL_EXP ? -t : -t * t), 0.0, 1.0);
    }
    float start = fogStart * float(FOG_START_SCALE);
    float end_  = fogEnd   * float(FOG_END_SCALE);
    // Keep at least one block between start and end.
    float mid   = 0.5 * (start + end_);
    float range = max(end_ - start, 1.0);
    return clamp((d - mid) / range + 0.5, 0.0, 1.0);
}

vec3 applyFog(vec3 rgb, vec3 viewPos) {
    float d = fogShape == 1
        ? length((mat3(gbufferModelViewInverse) * viewPos).xz)
        : length(viewPos);
    return mix(rgb, fogColor, fogFactor(d));
}

#endif
