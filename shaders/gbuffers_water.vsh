#version 410 compatibility
#include "/shaders.settings"
#define VSH
#include "/lib/vertex.glsl"

attribute vec4 mc_Entity;

flat out int blockId;

void main() {
    emitVertex();
    blockId = int(mc_Entity.x + 0.5);
}
