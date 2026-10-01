#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/texmap.glsl"

uniform vec4 entityColor;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec4 c = albedo(texmap(texcoord));
    if (c.a <= 0.0) discard;

    c.rgb = mix(c.rgb, entityColor.rgb, entityColor.a);
#if MC_VERSION < 12102
    // Emissive layers fade out before 1.21.2, then blend to the fog color.
    c *= 1.0 - fogFactor(viewPos);
#else
    c.rgb = applyFog(c.rgb, viewPos);
#endif
    out0 = c;
}
