// Shared samplers and lightmap.

#ifndef COMMON_GLSL
#define COMMON_GLSL

uniform sampler2D gtexture;
uniform sampler2D lightmap;

// Lightmap color with an ambient floor (AMBIENT_FLOOR) and its luminance
// quantized to DOS_LIGHT_STEPS levels, keeping the tint (colormap banding).
vec3 applyLightmap(vec2 lmuv) {
    vec3 lm = mix(texture(lightmap, lmuv).rgb, vec3(1.0), clamp(float(AMBIENT_FLOOR), 0.0, 1.0));

    #if (DOS_LIGHT_STEPS > 1)
        float y  = dot(lm, vec3(0.2126, 0.7152, 0.0722));
        float qs = float(DOS_LIGHT_STEPS - 1);
        lm *= (floor(y * qs + 0.5) / qs) / max(y, 1e-6);
    #endif

    return lm;
}

#endif
