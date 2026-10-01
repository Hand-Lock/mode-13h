#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = albedo(texcoord);
    if (c.a < alphaTestRef) discard;
    // Vanilla fades clouds out with distance instead of fogging them.
    c.a *= 1.0 - fogFactor(fogDistance(viewPos));
    out0 = c;
}
