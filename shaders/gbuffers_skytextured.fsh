#version 410 compatibility

uniform sampler2D gtexture;
uniform float alphaTestRef;

varying vec2 texcoord;
varying vec4 vColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 out0;

void main() {
    vec4 c = texture2D(gtexture, texcoord) * vColor;
    if (c.a < alphaTestRef) discard;
    out0 = c;
}
