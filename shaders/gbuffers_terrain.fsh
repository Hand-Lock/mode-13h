#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/affine.glsl"

flat in int noAffine;

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec2 uv = (noAffine == 1) ? texcoord : affineUV(texcoord, texcoord_np, viewPos);

    vec4 c = albedo(uv);
    if (c.a < alphaTestRef) discard;

    c.rgb *= applyLightmap(lmcoord);
    c.rgb  = applyFog(c.rgb, viewPos);
    out0 = c;
}
