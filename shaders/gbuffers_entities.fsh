#version 410 compatibility
#include "/shaders.settings"
#include "/lib/common.glsl"
#include "/lib/fog.glsl"
#include "/lib/affine.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

varying vec2 texcoord;
noperspective varying vec2 texcoord_np;
varying vec2 lmcoord;
varying vec4 vColor;

uniform vec4  entityColor;
uniform float alphaTestRef;

void main() {
    vec2 uv  = affineUV(texcoord, texcoord_np);
    vec4 base = texture2D(texture, uv) * vColor;
    if (base.a < alphaTestRef) discard;

    base.rgb *= applyLightmap(lmcoord.xy);
    base.rgb  = mix(base.rgb, entityColor.rgb, entityColor.a);
    base.rgb  = applyFog(base.rgb);

    out0 = base;
}
