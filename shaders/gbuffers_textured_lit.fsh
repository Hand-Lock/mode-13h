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

void main() {
    vec2 uv = affineUV(texcoord, texcoord_np);

    vec4 c = texture2D(texture, uv) * vColor;
    c.rgb *= applyLightmap(lmcoord.xy);
    c.rgb  = applyFog(c.rgb);
    out0 = c;
}
