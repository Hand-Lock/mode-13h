#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    out0 = vec4(applyFog(vColor.rgb, viewPos), vColor.a);
}
