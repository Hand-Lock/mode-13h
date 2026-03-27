#version 410 compatibility
#include "/shaders.settings"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;

uniform float alphaTestRef;

float bayer4x4(ivec2 p) {
    p = ivec2(p.x & 3, p.y & 3);

    if (p.y == 0) {
        if (p.x == 0) return  0.0 / 16.0;
        if (p.x == 1) return  8.0 / 16.0;
        if (p.x == 2) return  2.0 / 16.0;
        return 10.0 / 16.0;
    } else if (p.y == 1) {
        if (p.x == 0) return 12.0 / 16.0;
        if (p.x == 1) return  4.0 / 16.0;
        if (p.x == 2) return 14.0 / 16.0;
        return  6.0 / 16.0;
    } else if (p.y == 2) {
        if (p.x == 0) return  3.0 / 16.0;
        if (p.x == 1) return 11.0 / 16.0;
        if (p.x == 2) return  1.0 / 16.0;
        return  9.0 / 16.0;
    } else {
        if (p.x == 0) return 15.0 / 16.0;
        if (p.x == 1) return  7.0 / 16.0;
        if (p.x == 2) return 13.0 / 16.0;
        return  5.0 / 16.0;
    }
}

vec3 applyHandDither(vec3 c) {
#if (HAND_DITHER == 1)
    ivec2 p = ivec2(gl_FragCoord.xy) / DOS_SCALE;
    float d = bayer4x4(p) - (7.5 / 16.0);
    c += vec3(d * HAND_DITHER_STRENGTH * (1.0 / 16.0));
    return clamp(c, 0.0, 1.0);
#else
    return c;
#endif
}

void main() {
    vec4 c = texture2D(texture, texcoord) * vColor;
    if (c.a < alphaTestRef) discard;

#if (HAND_FLATTEN == 0)
    c.rgb *= applyLightmap(lmcoord.xy);
#endif

    c.rgb = applyFog(c.rgb);

#if (HAND_DITHER == 1)
    c.rgb = applyHandDither(c.rgb);
#endif

    out0 = c;
}