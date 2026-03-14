#version 410 compatibility
#include "/shaders.settings"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/affine.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

varying vec2 texcoord;
noperspective varying vec2 texcoord_np;
varying vec2 lmcoord;
varying vec4 vColor;
flat in int blockId;

void main() {
    vec2 uv = affineUV(texcoord, texcoord_np);

    vec4 c = texture2D(texture, uv) * vColor;

    vec3 lm = applyLightmap(lmcoord.xy);
    c.rgb  *= lm;

    // Water tweak notturno solo per veri blocchi acqua
    if (blockId == 10001) {
        float ambient = clamp(max(lm.r, max(lm.g, lm.b)), 0.0, 1.0);
        float night   = smoothstep(0.0, 0.6, 1.0 - ambient);
        c.a = max(c.a, mix(0.0, 0.85, night));
        c.rgb = mix(c.rgb, c.rgb * 0.75, night);
    }

    c.rgb = applyFog(c.rgb);
    out0 = c;
}
