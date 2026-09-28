// Shared samplers and lightmap.

#ifndef COMMON_GLSL
#define COMMON_GLSL

uniform sampler2D gtexture;
uniform sampler2D lightmap;

// Apply lightmap with ambient floor and optional luminance quantization.
// AMBIENT_FLOOR and DOS_LIGHT_STEPS are defined in shaders.settings.
vec3 applyLightmap(vec2 lmuv) {
    vec3 lm = texture(lightmap, lmuv).rgb;

    // Raise the floor to avoid pure-black pixels
    float a = clamp(float(AMBIENT_FLOOR), 0.0, 1.0);
    lm = lm * (1.0 - a) + vec3(a);

    // Quantize luminance to discrete steps (DOS colormap banding)
    #if (DOS_LIGHT_STEPS > 1)
        float y  = dot(lm, vec3(0.2126, 0.7152, 0.0722));
        float qs = float(DOS_LIGHT_STEPS - 1);
        float yq = floor(y * qs + 0.5) / qs;

        // Preserve lightmap tint, quantize intensity only
        if (y > 1e-6) {
            lm *= (yq / y);
        } else {
            lm = vec3(0.0);
        }
    #endif

    return lm;
}

#endif
