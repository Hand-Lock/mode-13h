#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

// Untextured; fades out with distance like vanilla, since the fog color
// would glow under its additive blend.
void main() {
    out0 = vColor * (1.0 - fogFactor(viewPos));
}
