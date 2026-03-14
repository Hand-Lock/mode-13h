#version 410 compatibility
#include "/shaders.settings"
#include "/lib/fog.glsl"
varying vec4 vColor;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = vColor;
    c.rgb = applyFog(c.rgb);
    out0 = c;
}
