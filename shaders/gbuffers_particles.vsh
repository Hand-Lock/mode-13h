#version 410 compatibility
#include "/shaders.settings"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor   = gl_Color;
    gl_Position = ftransform(); // particles are already billboarded by the engine
}
