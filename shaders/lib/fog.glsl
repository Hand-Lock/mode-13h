// Vanilla fog for the running Minecraft version (ADR 0017), with start and end
// scaled by FOG_START_SCALE and FOG_END_SCALE (1.00 = vanilla).

#ifndef FOG_GLSL
#define FOG_GLSL

uniform vec3  fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform int   fogShape;  // 0 = sphere, 1 = cylinder (before 1.21.6)
uniform float far;
uniform float blindness;
uniform float darknessFactor;
uniform int   isEyeInWater;

uniform mat4 gbufferModelViewInverse;

// View space to player space (world-aligned, camera at the origin).
vec3 fogPlayer(vec3 viewPos) {
    return mat3(gbufferModelViewInverse) * viewPos;
}

// Vanilla's cylindrical distance.
float fogCyl(vec3 p) {
    return max(length(p.xz), abs(p.y));
}

// 0 → 1 from the scaled start to the scaled end, at least one block apart.
// Smoothstep before 1.21.6, linear since.
float fogRamp(float d, float start, float end_) {
    start *= float(FOG_START_SCALE);
    end_  *= float(FOG_END_SCALE);
    float mid = 0.5 * (start + end_);
    float t   = clamp((d - mid) / max(end_ - start, 1.0) + 0.5, 0.0, 1.0);
#if MC_VERSION < 12106
    t = t * t * (3.0 - 2.0 * t);
#endif
    return t;
}

// Water, lava, powder snow, blindness or darkness: environments whose fog
// replaces the sky and cloud distances on 1.21.6+.
bool fogSpecial() {
    return isEyeInWater != 0 || blindness > 0.0 || darknessFactor > 0.0;
}

float fogFactor(vec3 viewPos) {
#if MC_VERSION < 12106
    float d = fogShape == 1 ? fogCyl(fogPlayer(viewPos)) : length(viewPos);
    return fogRamp(d, fogStart, fogEnd);
#else
    // Environmental fog, or render-distance fog toward the edge of the world.
    return max(fogRamp(length(viewPos), fogStart, fogEnd),
               fogRamp(fogCyl(fogPlayer(viewPos)), far - clamp(far / 10.0, 4.0, 64.0), far));
#endif
}

vec3 applyFog(vec3 rgb, vec3 viewPos) {
    return mix(rgb, fogColor, fogFactor(viewPos));
}

#endif
