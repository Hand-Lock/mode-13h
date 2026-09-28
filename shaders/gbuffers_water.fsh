#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/texmap.glsl"

flat in int blockId;
in vec4 uvRect;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = albedo(texmap(texcoord, uvRect));

    vec3 lm = applyLightmap(lmcoord);
    c.rgb  *= lm;

    // Water only: darker and more opaque in low light
    if (blockId == 10001) {
        float night = smoothstep(0.0, 0.6, 1.0 - clamp(max(lm.r, max(lm.g, lm.b)), 0.0, 1.0));
        c.a    = max(c.a, 0.85 * night);
        c.rgb *= 1.0 - 0.25 * night;
    }

    c.rgb = applyFog(c.rgb, viewPos);
    out0 = c;
}
