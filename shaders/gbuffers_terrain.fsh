#version 410 compatibility
#include "/shaders.settings"
#include "/lib/vertex.glsl"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/texmap.glsl"

flat in int noAffine;
flat in int billy;
in vec4 uvRect;

uniform float alphaTestRef;

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

void main() {
    vec2 uv = (noAffine == 1) ? texcoord : texmap(texcoord, uvRect);

    vec4 c = albedo(uv);
    if (c.a < alphaTestRef) discard;
#if BILLY_BOARDING == 1
    // Billy Boarding's solid-layer blocks (cake, anvil, bell) ignore its
    // render_type hint on Fabric, and alphaTestRef is 0 in the solid layer.
    if (billy == 1 && c.a < 0.1) discard;
#endif

    c.rgb *= applyLightmap(lmcoord);
    c.rgb  = applyFog(c.rgb, viewPos);
    out0 = c;
}
