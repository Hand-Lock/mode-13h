// Shared samplers, texture fetch and lightmap. Needs vertex.glsl first.

#ifndef COMMON_GLSL
#define COMMON_GLSL

#include "/lib/palette.glsl"

uniform sampler2D gtexture;
uniform sampler2D lightmap;

// Tinted texel. The mip bias of log2(DOS_SCALE) filters textures for the
// resolution that is shown (one sample per cell), so they don't shimmer.
// With DOS_COLORMAP the texel is snapped to the palette before lighting, so
// final's palette pass moves shading along the palette's ramps (ADR 0011).
vec4 albedo(vec2 uv) {
    vec4 c = texture(gtexture, uv, log2(float(DOS_SCALE))) * vColor;
#if (DOS_COLORMAP == 1)
    c.rgb = palettize(c.rgb);
#endif
    return c;
}

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

// 26.3+ draws the enchantment glint inside the item's own draw, and Iris
// hands it over as mc_sampleGlint() instead of running armor_glint.
// Vanilla adds it squared (BlendFunction.GLINT), after light, before fog.
vec3 inlineGlint() {
#ifdef IRIS_INLINE_GLINT
    vec3 g = mc_sampleGlint();
    return g * g;
#else
    return vec3(0.0);
#endif
}

#endif
