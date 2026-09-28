#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

const float BAYER4[16] = float[16](
     0.0,  8.0,  2.0, 10.0,
    12.0,  4.0, 14.0,  6.0,
     3.0, 11.0,  1.0,  9.0,
    15.0,  7.0, 13.0,  5.0);

void main() {
    vec4 c = albedo(texcoord);
    if (c.a < alphaTestRef) discard;

#if (HAND_FLATTEN == 0)
    c.rgb *= applyLightmap(lmcoord);
#endif

    c.rgb = applyFog(c.rgb, viewPos);

#if (HAND_DITHER == 1)
    // 4x4 ordered dither at macro-pixel scale
    ivec2 p = (ivec2(gl_FragCoord.xy) / DOS_SCALE) & 3;
    float d = (BAYER4[p.y * 4 + p.x] - 7.5) / 16.0;
    c.rgb = clamp(c.rgb + d * float(HAND_DITHER_STRENGTH) / 16.0, 0.0, 1.0);
#endif

    out0 = c;
}
