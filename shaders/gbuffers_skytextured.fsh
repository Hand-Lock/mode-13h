#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = albedo(texcoord);
    if (c.a < alphaTestRef) discard;
    out0 = c;
}
