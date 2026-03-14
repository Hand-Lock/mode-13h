#version 410 compatibility
#include "/shaders.settings"

varying vec2 texcoord;
varying vec4 vColor;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor   = gl_Color;
    gl_Position = ftransform();
}
