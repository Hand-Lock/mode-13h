#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

// Vanilla cloud fog per version (ADR 0016).
void main() {
    vec4 c = albedo(texcoord);
    if (c.a < alphaTestRef) discard;
#if MC_VERSION < 12100
    // Terrain fog, spherical. Sodium swaps in its own cloud range, so rebuild
    // vanilla's from the render distance; in fluids Iris's range is vanilla's.
    float start = fogStart, end_ = fogEnd;
    if (isEyeInWater == 0) {
        end_  = max(far, 32.0);
        start = end_ - clamp(end_ / 10.0, 4.0, 64.0);
        if (blindness > 0.0) {
            end_  = mix(end_, 5.0, blindness);
            start = 0.25 * end_;
        } else if (darknessFactor > 0.0) {
            end_  = mix(end_, 15.0, darknessFactor);
            start = 0.75 * end_;
        }
    }
    c.rgb = mix(c.rgb, fogColor, fogRamp(length(viewPos), start, end_));
#elif MC_VERSION < 12102
    // Terrain fog with a view-space cylinder.
    float d = fogShape == 1 ? fogCyl(viewPos) : length(viewPos);
    c.rgb = mix(c.rgb, fogColor, fogRamp(d, fogStart, fogEnd));
#elif MC_VERSION < 12106
    c.rgb = applyFog(c.rgb, viewPos);
#else
    // Iris's face colors repeat CloudColor's α 0.8; vanilla has it once.
    c.a /= 0.8;
    // Fade out by the cloud distance, no fog color.
    c.a *= 1.0 - fogRamp(length(viewPos), 0.0, fogSpecial() ? fogEnd
                               : min(float(CLOUD_DISTANCE) * 16.0, 2048.0));
#endif
    out0 = c;
}
