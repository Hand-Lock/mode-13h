#version 410 compatibility
#include "/shaders.settings"
#define VSH
#include "/lib/vertex.glsl"

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

flat out int blockId;
out vec4 uvRect;

void main() {
    vec2 uv = vertexUV();
    emitVertex(gl_Vertex, uv);
    blockId = int(mc_Entity.x + 0.5);

    // The face's UV rectangle for texmap(): mc_midTexCoord is its center.
    vec2 h = abs(uv - mc_midTexCoord);
    uvRect = vec4(mc_midTexCoord - h, mc_midTexCoord + h);
}
