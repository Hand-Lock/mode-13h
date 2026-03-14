#version 410 compatibility
#include "/shaders.settings"

varying vec2 texcoord;
noperspective varying vec2 texcoord_np;
varying vec2 lmcoord;
varying vec4 vColor;

attribute vec4 mc_Entity;
flat out int blockId;

void main() {
    texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    texcoord_np = texcoord;
    lmcoord     = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor      = gl_Color;

    blockId = int(mc_Entity.x + 0.5); // 10001 = water (Iris/OptiFine convention)

    gl_Position = ftransform();
}
