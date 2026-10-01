#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/texmap.glsl"

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

// Vanilla's glint ignores light and fades out with distance instead of
// taking the fog color, which its additive blend would make glow.
void main() {
    vec4 c = albedo(texmap(texcoord));
    if (c.a < alphaTestRef) discard;

    c.rgb *= 1.0 - fogFactor(viewPos);
    out0 = c;
}
