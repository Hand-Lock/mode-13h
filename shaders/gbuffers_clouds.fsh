#version 410 compatibility
#include "/shaders.settings"
#include "/lib/fog.glsl"

/* RENDERTARGETS: 0 */
layout(location=0) out vec4 out0;

varying vec2 texcoord;
varying vec4 vColor;

uniform sampler2D gtexture;
uniform float     alphaTestRef;

void main() {
    vec4 c = texture2D(gtexture, texcoord) * vColor;
    if (c.a < alphaTestRef) discard;
    c.rgb = applyFog(c.rgb);
    out0 = c;
}
