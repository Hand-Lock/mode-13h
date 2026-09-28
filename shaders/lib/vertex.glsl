// Varyings shared by every gbuffers program, and the vertex code that fills
// them. Include from both stages; a .vsh defines VSH first to get emitVertex().

#ifndef VERTEX_GLSL
#define VERTEX_GLSL

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 viewPos;
noperspective varying vec2 texcoord_np;

#ifdef VSH
vec2 vertexUV() {
    return (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

// Fill the varyings and gl_Position from a model-space vertex and its UV.
void emitVertex(vec4 vertex, vec2 uv) {
    texcoord    = uv;
    texcoord_np = uv;
    lmcoord     = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor      = gl_Color;
    viewPos     = (gl_ModelViewMatrix * vertex).xyz;
    gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);
}

void emitVertex() {
    emitVertex(gl_Vertex, vertexUV());
}
#endif

#endif
