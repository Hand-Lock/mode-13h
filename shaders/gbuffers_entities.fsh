#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/texmap.glsl"

uniform vec4  entityColor;
uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = albedo(texmap(texcoord));
    if (c.a < alphaTestRef) discard;

    c.rgb *= applyLightmap(lmcoord);
    c.rgb  = mix(c.rgb, entityColor.rgb, entityColor.a);
    c.rgb += inlineGlint();
    c.rgb  = applyFog(c.rgb, viewPos);
    out0 = c;
}
