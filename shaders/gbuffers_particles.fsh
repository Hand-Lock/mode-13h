#version 410 compatibility
#include "/shaders.settings"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;

void main() {
    vec4 c = texture2D(texture, texcoord) * vColor;
    if (c.a <= 0.0) discard;

    c.rgb *= applyLightmap(lmcoord.xy);
    c.rgb  = applyFog(c.rgb);
    out0 = c;
}
